import 'dart:convert';
import 'package:flutter/material.dart';

class PDFAnnotationTools extends StatefulWidget {
  final Function(String) onAnnotationAdded;

  const PDFAnnotationTools({
    Key? key,
    required this.onAnnotationAdded,
  }) : super(key: key);

  @override
  State<PDFAnnotationTools> createState() => _PDFAnnotationToolsState();
}

class _PDFAnnotationToolsState extends State<PDFAnnotationTools> {
  String _selectedTool = 'pen';
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;
  List<DrawingPoint> _points = [];
  bool _isDrawing = false;
  
  // Text annotation properties
  String _textInput = '';
  Offset? _textPosition;
  List<TextAnnotation> _textAnnotations = [];
  
  // Signature properties
  bool _isSignatureMode = false;
  List<DrawingPoint> _signaturePoints = [];
  Offset? _signaturePosition;
  List<SignatureAnnotation> _signatureAnnotations = [];

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.black,
    Colors.yellow,
    Colors.orange,
  ];

  final List<Map<String, dynamic>> _tools = [
    {'name': 'pen', 'icon': Icons.edit},
    {'name': 'highlighter', 'icon': Icons.highlight},
    {'name': 'eraser', 'icon': Icons.auto_fix_high},
    {'name': 'text', 'icon': Icons.text_fields},
    {'name': 'signature', 'icon': Icons.draw},
  ];

  void _addAnnotation() {
    // Handle different annotation types
    if (_selectedTool == 'text' && _textPosition != null && _textInput.isNotEmpty) {
      // Add text annotation
      final textAnnotation = TextAnnotation(
        text: _textInput,
        position: _textPosition!,
        color: _selectedColor,
        fontSize: _strokeWidth * 5, // Scale stroke width to reasonable font size
      );
      
      setState(() {
        _textAnnotations.add(textAnnotation);
        _textPosition = null;
        _textInput = '';
      });
      
      // Convert text annotation to JSON
      final annotationData = jsonEncode({
        'type': 'text',
        'text': textAnnotation.text,
        'x': textAnnotation.position.dx,
        'y': textAnnotation.position.dy,
        'color': textAnnotation.color.value.toString(),
        'fontSize': textAnnotation.fontSize,
      });
      
      widget.onAnnotationAdded(annotationData);
    } 
    else if (_selectedTool == 'signature' && _signaturePosition != null && _signaturePoints.isNotEmpty) {
      // Add signature annotation
      final signatureAnnotation = SignatureAnnotation(
        points: List.from(_signaturePoints),
        position: _signaturePosition!,
        color: _selectedColor,
        strokeWidth: _strokeWidth,
      );
      
      setState(() {
        _signatureAnnotations.add(signatureAnnotation);
        _signaturePosition = null;
        _signaturePoints = [];
        _isSignatureMode = false;
      });
      
      // Convert signature annotation to JSON
      final annotationData = jsonEncode({
        'type': 'signature',
        'x': signatureAnnotation.position.dx,
        'y': signatureAnnotation.position.dy,
        'color': signatureAnnotation.color.value.toString(),
        'strokeWidth': signatureAnnotation.strokeWidth,
        'points': signatureAnnotation.points.map((point) => {
          'x': point.offset.dx,
          'y': point.offset.dy,
          'pressure': point.pressure,
        }).toList(),
      });
      
      widget.onAnnotationAdded(annotationData);
    }
    else if (_points.isNotEmpty) {
      // Handle regular drawing annotations
      final annotationData = jsonEncode({
        'type': _selectedTool,
        'color': _selectedColor.value.toString(),
        'strokeWidth': _strokeWidth,
        'points': _points.map((point) => {
          'x': point.offset.dx,
          'y': point.offset.dy,
          'pressure': point.pressure,
        }).toList(),
      });

      widget.onAnnotationAdded(annotationData);

      // Clear points after saving
      setState(() {
        _points = [];
      });
    }
  }

  // Method to show text input dialog
  void _showTextInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Text'),
          content: TextField(
            onChanged: (value) {
              _textInput = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter text to add',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_textInput.isNotEmpty && _textPosition != null) {
                  setState(() {
                    _textAnnotations.add(TextAnnotation(
                      text: _textInput,
                      position: _textPosition!,
                      color: _selectedColor,
                      fontSize: _strokeWidth * 5,
                    ));
                  });
                  _addAnnotation();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawing area
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Display existing text annotations
                ...(_textAnnotations.map((textAnnotation) => Positioned(
                  left: textAnnotation.position.dx,
                  top: textAnnotation.position.dy,
                  child: Text(
                    textAnnotation.text,
                    style: TextStyle(
                      color: textAnnotation.color,
                      fontSize: textAnnotation.fontSize,
                    ),
                  ),
                ))),
                
                // Display existing signature annotations
                ...(_signatureAnnotations.map((signatureAnnotation) => Positioned(
                  left: signatureAnnotation.position.dx,
                  top: signatureAnnotation.position.dy,
                  child: CustomPaint(
                    size: const Size(100, 50), // Adjust size as needed
                    painter: SignaturePainter(points: signatureAnnotation.points),
                  ),
                ))),
                
                // Main drawing area with gesture detection
                GestureDetector(
                  onTapDown: (details) {
                    if (_selectedTool == 'text') {
                      // Set text position and show text input dialog
                      setState(() {
                        _textPosition = details.localPosition;
                      });
                      _showTextInputDialog(context);
                    } else if (_selectedTool == 'signature') {
                      // Set signature position and enable signature mode
                      setState(() {
                        _signaturePosition = details.localPosition;
                        _isSignatureMode = true;
                      });
                    }
                  },
                  onPanStart: (details) {
                    if (_selectedTool == 'signature' && _isSignatureMode) {
                      setState(() {
                        _signaturePoints.add(
                          DrawingPoint(
                            offset: details.localPosition - _signaturePosition!,
                            pressure: 1.0,
                            color: _selectedColor,
                            strokeWidth: _strokeWidth,
                          ),
                        );
                      });
                    } else if (_selectedTool != 'text') {
                      setState(() {
                        _isDrawing = true;
                        _points.add(
                          DrawingPoint(
                            offset: details.localPosition,
                            pressure: 1.0,
                            color: _selectedTool == 'eraser' ? Colors.white : _selectedColor,
                            strokeWidth: _selectedTool == 'highlighter' ? 10.0 : _strokeWidth,
                          ),
                        );
                      });
                    }
                  },
                  onPanUpdate: (details) {
                    if (_selectedTool == 'signature' && _isSignatureMode) {
                      setState(() {
                        _signaturePoints.add(
                          DrawingPoint(
                            offset: details.localPosition - _signaturePosition!,
                            pressure: 1.0,
                            color: _selectedColor,
                            strokeWidth: _strokeWidth,
                          ),
                        );
                      });
                    } else if (_isDrawing) {
                      setState(() {
                        _points.add(
                          DrawingPoint(
                            offset: details.localPosition,
                            pressure: 1.0,
                            color: _selectedTool == 'eraser' ? Colors.white : _selectedColor,
                            strokeWidth: _selectedTool == 'highlighter' ? 10.0 : _strokeWidth,
                          ),
                        );
                      });
                    }
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _isDrawing = false;
                    });
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: DrawingPainter(
                      points: _points,
                      textAnnotations: _textAnnotations,
                      signatureAnnotations: _signatureAnnotations,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tool selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _tools.map((tool) {
              return IconButton(
                icon: Icon(tool['icon']),
                color: _selectedTool == tool['name'] ? Colors.blue : Colors.grey,
                onPressed: () {
                  setState(() {
                    _selectedTool = tool['name'];
                  });
                },
                tooltip: tool['name'].toString().capitalize(),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Color selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Stroke width slider
          Row(
            children: [
              const Text('Stroke Width:'),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 1.0,
                  max: 10.0,
                  onChanged: (value) {
                    setState(() {
                      _strokeWidth = value;
                    });
                  },
                ),
              ),
              Text(_strokeWidth.toStringAsFixed(1)),
            ],
          ),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _points = [];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                ),
                child: const Text('Clear'),
              ),
              ElevatedButton(
                onPressed: _addAnnotation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Annotation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawingPoint {
  final Offset offset;
  final double pressure;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.offset,
    required this.pressure,
    required this.color,
    required this.strokeWidth,
  });
}

class TextAnnotation {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;

  TextAnnotation({
    required this.text,
    required this.position,
    required this.color,
    required this.fontSize,
  });
}

class SignatureAnnotation {
  final List<DrawingPoint> points;
  final Offset position;
  final Color color;
  final double strokeWidth;

  SignatureAnnotation({
    required this.points,
    required this.position,
    required this.color,
    required this.strokeWidth,
  });
}

class SignaturePainter extends CustomPainter {
  final List<DrawingPoint> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final List<TextAnnotation> textAnnotations;
  final List<SignatureAnnotation> signatureAnnotations;

  DrawingPainter({
    required this.points,
    this.textAnnotations = const [],
    this.signatureAnnotations = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw regular points
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
    
    // Draw text annotations
    for (var textAnnotation in textAnnotations) {
      final textStyle = TextStyle(
        color: textAnnotation.color,
        fontSize: textAnnotation.fontSize,
      );
      final textSpan = TextSpan(
        text: textAnnotation.text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, textAnnotation.position);
    }
    
    // Draw signature annotations
    for (var signatureAnnotation in signatureAnnotations) {
      final paint = Paint()
        ..color = signatureAnnotation.color
        ..strokeWidth = signatureAnnotation.strokeWidth
        ..strokeCap = StrokeCap.round;
      
      for (int i = 0; i < signatureAnnotation.points.length - 1; i++) {
        final point = signatureAnnotation.points[i];
        final nextPoint = signatureAnnotation.points[i + 1];
        
        // Adjust points based on signature position
        final adjustedPoint = point.offset + signatureAnnotation.position;
        final adjustedNextPoint = nextPoint.offset + signatureAnnotation.position;
        
        canvas.drawLine(adjustedPoint, adjustedNextPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points || 
           oldDelegate.textAnnotations != textAnnotations || 
           oldDelegate.signatureAnnotations != signatureAnnotations;
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
