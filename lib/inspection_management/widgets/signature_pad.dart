import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final Function(String) onSignatureCapture;

  const SignaturePad({
    Key? key,
    required this.onSignatureCapture,
  }) : super(key: key);

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDrawing = true;
                  _currentStroke = [details.localPosition];
                });
              },
              onPanUpdate: (details) {
                if (_isDrawing) {
                  setState(() {
                    _currentStroke.add(details.localPosition);
                  });
                }
              },
              onPanEnd: (details) {
                if (_isDrawing) {
                  setState(() {
                    _isDrawing = false;
                    if (_currentStroke.isNotEmpty) {
                      _strokes.add(List.from(_currentStroke));
                      _currentStroke = [];
                    }
                  });
                }
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: SignaturePainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _clear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                ),
                child: const Text('Clear'),
              ),
              ElevatedButton(
                onPressed: _strokes.isEmpty ? null : _captureSignature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Signature'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _clear() {
    setState(() {
      _strokes = [];
      _currentStroke = [];
    });
  }

  Future<void> _captureSignature() async {
    if (_strokes.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, context.size!.width, context.size!.height),
      Paint()..color = Colors.white,
    );

    // Draw all strokes
    for (final stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      context.size!.width.toInt(),
      context.size!.height.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Convert to base64
    final base64Image = 'data:image/png;base64,${base64Encode(buffer)}';
    
    // Pass the signature data back
    widget.onSignatureCapture(base64Image);
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  SignaturePainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw completed strokes
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    // Draw current stroke
    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.currentStroke != currentStroke;
  }
}
