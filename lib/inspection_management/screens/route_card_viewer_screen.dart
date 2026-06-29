import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/route_card_model.dart';
import '../widgets/pdf_annotation_tools.dart';
import '../../shared/services/http_file_upload_service.dart';
import '../services/pdf_overlay_service.dart';

class RouteCardViewerScreen extends StatefulWidget {
  final String workOrderId;
  final String pdfUrl;

  const RouteCardViewerScreen({
    Key? key,
    required this.workOrderId,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  State<RouteCardViewerScreen> createState() => _RouteCardViewerScreenState();
}

class _RouteCardViewerScreenState extends State<RouteCardViewerScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  PDFViewController? _pdfController;
  bool _isLoading = true;
  String _errorMessage = '';
  File? _pdfFile;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isInspectionMode = false;
  bool _isAnnotationMode = false;
  bool _isTextBoxMode = false; // New mode for adding/editing text boxes
  RouteCard? _routeCard;
  List<PieceMark> _pieceMarks = [];
  PieceMark? _currentPieceMark;
  
  // Variables for dragging text annotations
  bool _isDragging = false;
  String? _draggedPointName;
  int? _draggedPageNumber;
  Offset _dragOffset = Offset.zero;
  double _initialFontSize = 12.0;
  
  // GlobalKey to get PDF viewer widget size
  final GlobalKey _pdfViewKey = GlobalKey();
  
  // Position offset adjustment (can be tuned if there's systematic offset)
  static const double _positionOffsetX = 0.0;
  static const double _positionOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
    _loadRouteCardData();
  }

  Future<void> _loadPdf() async {
    print('DEBUG: Starting PDF loading for workOrderId: ${widget.workOrderId}');
    print('DEBUG: PDF URL: ${widget.pdfUrl}');
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      File file;
      
      // Check if this is an HTTP URL or local file path
      if (widget.pdfUrl.startsWith('http://') || widget.pdfUrl.startsWith('https://')) {
        // This is a server URL - download it
        print('📥 Downloading PDF from server: ${widget.pdfUrl}');
        
        final appDir = await getApplicationDocumentsDirectory();
        final tempDir = Directory('${appDir.path}/temp');
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }
        
        final filePath = '${tempDir.path}/${widget.workOrderId}_temp.pdf';
        
        // Download from custom server
        file = await HttpFileUploadService.downloadPdf(widget.pdfUrl, filePath);
        print('✅ PDF downloaded successfully from server');
      } else {
        // This is a local file path - use it directly
        print('📂 Using local file: ${widget.pdfUrl}');
        file = File(widget.pdfUrl);
        
        if (!await file.exists()) {
          throw Exception('Local PDF file does not exist: ${widget.pdfUrl}');
        }
        
        print('✅ Local PDF file found');
      }
      
      setState(() {
        _pdfFile = file;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading PDF: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  Future<void> _loadRouteCardData() async {
    try {
      // Check if route card exists
      final routeCardQuery = await FirebaseFirestore.instance
          .collection('route_cards')
          .where('workOrderId', isEqualTo: widget.workOrderId)
          .limit(1)
          .get();

      if (routeCardQuery.docs.isNotEmpty) {
        // Route card exists, load it
        _routeCard = RouteCard.fromFirestore(routeCardQuery.docs.first);
        _pieceMarks = _routeCard!.pieceMarks;
      } else {
        // Route card doesn't exist, create a new one
        // This would typically be done when the PDF is first uploaded
        // For now, we'll just create an empty route card
      }
    } catch (e) {
      print('Error loading route card data: $e');
    }
  }

  Future<void> _createOrUpdatePieceMark(int pageNumber) async {
    // Find if there's already a piece mark for this page
    PieceMark? existingPieceMark;
    for (var pieceMark in _pieceMarks) {
      if (pieceMark.pageNumber == pageNumber) {
        existingPieceMark = pieceMark;
        break;
      }
    }
    
    if (existingPieceMark != null) {
      // Use existing piece mark
      setState(() {
        _currentPieceMark = existingPieceMark;
      });
    } else {
      // Create a new piece mark
      final newPieceMark = PieceMark(
        id: '',
        pageNumber: pageNumber,
        pieceMarkId: 'PM-$pageNumber',
        description: 'Inspection for page $pageNumber',
        inspectionPoints: {},
        inspectorSignature: '',
        inspectorId: '',
        inspectionDate: DateTime.now(),
        status: 'pending',
        annotations: [],
        remarks: '',
      );
      
      setState(() {
        _currentPieceMark = newPieceMark;
        _pieceMarks.add(newPieceMark);
      });
    }
    
    // Print debug information
    print('Current page number: $pageNumber');
    print('Current piece mark page number: ${_currentPieceMark?.pageNumber}');
    print('Total piece marks: ${_pieceMarks.length}');
    for (var pm in _pieceMarks) {
      print('Piece mark page ${pm.pageNumber} has ${pm.inspectionPoints.length} points');
    }
  }

  Future<void> _savePieceMarkData(PieceMark updatedPieceMark) async {
    try {
      // Update the piece mark in the list
      final index = _pieceMarks.indexWhere((pm) => pm.id == updatedPieceMark.id);
      if (index >= 0) {
        _pieceMarks[index] = updatedPieceMark;
      } else {
        _pieceMarks.add(updatedPieceMark);
      }
      
      // Save to Firestore
      final pieceMarkData = {
        'workOrderId': widget.workOrderId,
        'pageNumber': updatedPieceMark.pageNumber,
        'pieceMarkId': updatedPieceMark.pieceMarkId,
        'description': updatedPieceMark.description,
        'inspectorSignature': updatedPieceMark.inspectorSignature,
        'inspectorId': updatedPieceMark.inspectorId,
        'inspectionDate': Timestamp.fromDate(updatedPieceMark.inspectionDate),
        'status': updatedPieceMark.status,
        'annotations': updatedPieceMark.annotations,
        'remarks': updatedPieceMark.remarks,
      };
      
      // Add inspection points
      final inspectionPointsData = {};
      updatedPieceMark.inspectionPoints.forEach((key, point) {
        inspectionPointsData[key] = {
          'name': point.name,
          'value': point.value,
          'result': point.result,
        };
      });
      pieceMarkData['inspectionPoints'] = inspectionPointsData;
      
      if (updatedPieceMark.id.isEmpty) {
        // Create new document
        final docRef = await FirebaseFirestore.instance
            .collection('piece_marks')
            .add(pieceMarkData);
        
        // Update the ID in memory
        final newPieceMark = PieceMark(
          id: docRef.id,
          pageNumber: updatedPieceMark.pageNumber,
          pieceMarkId: updatedPieceMark.pieceMarkId,
          description: updatedPieceMark.description,
          inspectionPoints: updatedPieceMark.inspectionPoints,
          inspectorSignature: updatedPieceMark.inspectorSignature,
          inspectorId: updatedPieceMark.inspectorId,
          inspectionDate: updatedPieceMark.inspectionDate,
          status: updatedPieceMark.status,
          annotations: updatedPieceMark.annotations,
          remarks: updatedPieceMark.remarks,
        );
        
        // Update in the list
        final newIndex = _pieceMarks.indexWhere((pm) => pm.id.isEmpty && pm.pageNumber == updatedPieceMark.pageNumber);
        if (newIndex >= 0) {
          _pieceMarks[newIndex] = newPieceMark;
        }
        
        // Update current piece mark
        setState(() {
          _currentPieceMark = newPieceMark;
        });
      } else {
        try {
          // First check if the document exists
          final docSnapshot = await FirebaseFirestore.instance
              .collection('piece_marks')
              .doc(updatedPieceMark.id)
              .get();
              
          if (docSnapshot.exists) {
            // Update existing document
            await FirebaseFirestore.instance
                .collection('piece_marks')
                .doc(updatedPieceMark.id)
                .update(pieceMarkData);
          } else {
            // Document doesn't exist, create a new one
            final docRef = await FirebaseFirestore.instance
                .collection('piece_marks')
                .add(pieceMarkData);
                
            // Update the ID in memory
            final newPieceMark = PieceMark(
              id: docRef.id,
              pageNumber: updatedPieceMark.pageNumber,
              pieceMarkId: updatedPieceMark.pieceMarkId,
              description: updatedPieceMark.description,
              inspectionPoints: updatedPieceMark.inspectionPoints,
              inspectorSignature: updatedPieceMark.inspectorSignature,
              inspectorId: updatedPieceMark.inspectorId,
              inspectionDate: updatedPieceMark.inspectionDate,
              status: updatedPieceMark.status,
              annotations: updatedPieceMark.annotations,
              remarks: updatedPieceMark.remarks,
            );
            
            // Update in the list and current piece mark
            setState(() {
              // Find and replace the piece mark with the old ID
              final oldIndex = _pieceMarks.indexWhere((pm) => pm.id == updatedPieceMark.id);
              if (oldIndex >= 0) {
                _pieceMarks[oldIndex] = newPieceMark;
              }
              
              // Update current piece mark if it's the same one
              if (_currentPieceMark?.id == updatedPieceMark.id) {
                _currentPieceMark = newPieceMark;
              }
            });
          }
        } catch (docError) {
          print('Error checking document existence: $docError');
          // Fallback to creating a new document
          final docRef = await FirebaseFirestore.instance
              .collection('piece_marks')
              .add(pieceMarkData);
              
          print('Created new document with ID: ${docRef.id}');
        }
      }
    } catch (e) {
      print('Error saving piece mark data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving inspection data: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  /// Generates PDF with all inspection overlays and uploads to server
  Future<void> _saveAndUploadEditedPdf() async {
    try {
      if (_pdfFile == null) {
        print('❌ No PDF file to save');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No PDF file loaded'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Check if this is a server URL (not local file)
      if (!widget.pdfUrl.startsWith('http://') && !widget.pdfUrl.startsWith('https://')) {
        print('❌ Cannot update server - local file');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is a local file - cannot upload to server'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      print('💾 Saving PDF with inspection overlays to server...');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Updating PDF on server...'),
            ],
          ),
        ),
      );
      
      // Generate PDF with overlays
      final appDir = await getApplicationDocumentsDirectory();
      final tempPath = '${appDir.path}/temp_${widget.workOrderId}_edited.pdf';
      
      print('📄 Generating PDF with all inspection records...');
      final editedPdf = await PdfOverlayService.generatePdfWithOverlays(
        originalPdfFile: _pdfFile!,
        pieceMarks: _pieceMarks,
        outputPath: tempPath,
      );
      
      // Extract filename from URL
      final uri = Uri.parse(widget.pdfUrl);
      final fileName = uri.pathSegments.last;
      
      print('☁️ Uploading to server: $fileName');
      // Upload to server (replace original)
      await HttpFileUploadService.updatePdf(editedPdf, fileName);
      
      // Update local cached file
      await editedPdf.copy(_pdfFile!.path);
      print('✅ Local cache updated');
      
      // Clean up temp file
      if (await editedPdf.exists()) {
        await editedPdf.delete();
      }
      
      print('✅ PDF successfully updated on server');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF updated on server with all records'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving edited PDF: $e');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Marks inspection as complete: Saves all records, uploads PDF, updates status
  Future<void> _markInspectionComplete() async {
    try {
      print('🎯 Marking inspection as complete...');
      
      // Step 1: Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Finalizing inspection...'),
              SizedBox(height: 8),
              Text(
                '1. Saving all records\n2. Generating final PDF\n3. Uploading to server',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      
      // Step 2: Save all records to Firestore
      print('📝 Step 1/3: Saving all records...');
      await _saveAllChanges();
      
      // Step 3: Generate PDF with overlays and upload to server
      if (_pdfFile != null && widget.pdfUrl.startsWith('http')) {
        print('📄 Step 2/3: Generating PDF with overlays...');
        
        final appDir = await getApplicationDocumentsDirectory();
        final tempPath = '${appDir.path}/temp_${widget.workOrderId}_final.pdf';
        
        // Generate PDF with all inspection records
        final editedPdf = await PdfOverlayService.generatePdfWithOverlays(
          originalPdfFile: _pdfFile!,
          pieceMarks: _pieceMarks,
          outputPath: tempPath,
        );
        
        print('☁️ Step 3/3: Uploading final PDF to server...');
        // Extract filename from URL and upload
        final uri = Uri.parse(widget.pdfUrl);
        final fileName = uri.pathSegments.last;
        await HttpFileUploadService.updatePdf(editedPdf, fileName);
        
        // Clean up temp file
        if (await editedPdf.exists()) {
          await editedPdf.delete();
        }
      }
      
      // Step 4: Update route card status to completed
      if (_routeCard != null) {
        await FirebaseFirestore.instance
            .collection('route_cards')
            .doc(_routeCard!.id)
            .update({
          'status': 'completed',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Inspection Complete!'),
              ],
            ),
            content: const Text(
              'All records have been saved and the final PDF has been uploaded to the server.\n\nThe inspection has been marked as complete.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      print('✅ Inspection marked as complete successfully!');
      
    } catch (e) {
      print('❌ Error marking inspection as complete: $e');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Downloads the original PDF from server (with all records) to device storage
  Future<void> _downloadPdfToDevice() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Check if this is a server URL
      if (!widget.pdfUrl.startsWith('http://') && !widget.pdfUrl.startsWith('https://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot download - this is a local file'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      print('📥 Downloading original PDF from server to device...');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Downloading PDF from server...'),
            ],
          ),
        ),
      );
      
      // Get Downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }
      
      if (downloadsDir != null && !await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      
      // Download directly from server to Downloads folder
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'RouteCard_${widget.workOrderId}_$timestamp.pdf';
      final downloadPath = '${downloadsDir?.path}/$fileName';
      
      print('📥 Downloading to: $downloadPath');
      await HttpFileUploadService.downloadPdf(widget.pdfUrl, downloadPath);
      
      print('✅ PDF downloaded successfully');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF saved to Downloads/$fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error downloading PDF: $e');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Download failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Track the last tap position for record placement
  Offset? _lastTapPosition;
  
  void _showAddRecordDialog() {
    String recordValue = '';
    // Use a timestamp as a unique identifier for the record
    final recordName = 'Record-${DateTime.now().millisecondsSinceEpoch}';
    // Default to 'pass' for result
    const recordResult = 'pass';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Text Value',
                  hintText: 'Enter text to place on PDF',
                ),
                onChanged: (value) {
                  recordValue = value;
                },
                autofocus: true,
              ),
              if (_lastTapPosition != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Position: (${_lastTapPosition!.dx.toStringAsFixed(1)}, ${_lastTapPosition!.dy.toStringAsFixed(1)})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showSignatureDialog(recordName, recordValue.isEmpty ? 'Signature' : recordValue, recordResult);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Add Signature'),
            ),
            ElevatedButton(
              onPressed: () {
                if (recordValue.isNotEmpty && _lastTapPosition != null) {
                  _addInspectionRecord(
                    recordName, 
                    recordValue, 
                    recordResult, 
                    '',
                    _lastTapPosition!.dx,
                    _lastTapPosition!.dy,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Text'),
            ),
          ],
        );
      },
    );
  }
  
  /// Updates signature position and saves to database
  void _updateSignaturePosition(double newX, double newY) {
    if (_currentPieceMark == null) return;
    
    final updatedPieceMark = PieceMark(
      id: _currentPieceMark!.id,
      pageNumber: _currentPieceMark!.pageNumber,
      pieceMarkId: _currentPieceMark!.pieceMarkId,
      description: _currentPieceMark!.description,
      inspectionPoints: _currentPieceMark!.inspectionPoints,
      inspectorSignature: _currentPieceMark!.inspectorSignature,
      signatureX: newX,
      signatureY: newY,
      inspectorId: _currentPieceMark!.inspectorId,
      inspectionDate: _currentPieceMark!.inspectionDate,
      status: _currentPieceMark!.status,
      annotations: _currentPieceMark!.annotations,
      remarks: _currentPieceMark!.remarks,
    );
    
    setState(() {
      _currentPieceMark = updatedPieceMark;
      
      final index = _pieceMarks.indexWhere((pm) => pm.pageNumber == updatedPieceMark.pageNumber);
      if (index >= 0) {
        _pieceMarks[index] = updatedPieceMark;
      }
    });
    
    _savePieceMarkData(updatedPieceMark);
  }

  /// Shows a signature dialog for capturing inspector signature
  /// Updates the position of an inspection point and saves it to Firestore
  void _updateInspectionPointPosition(String pointName, int pageNumber, double newX, double newY) {
    // Find the piece mark for the page
    final pagePieceMark = _pieceMarks.firstWhere(
      (pm) => pm.pageNumber == pageNumber,
      orElse: () => PieceMark(
        id: '',
        pageNumber: pageNumber,
        pieceMarkId: 'PM-$pageNumber',
        description: 'Inspection for page $pageNumber',
        inspectionPoints: {},
        status: 'pending',
      ),
    );
    
    // If the piece mark doesn't exist or doesn't have the point, return
    if (pagePieceMark.id.isEmpty || !pagePieceMark.inspectionPoints.containsKey(pointName)) {
      print('Cannot update position: Piece mark or point not found');
      return;
    }
    
    // Get the current point
    final currentPoint = pagePieceMark.inspectionPoints[pointName]!;
    
    // Recalculate percentage position based on new absolute position
    double? newXPercent;
    double? newYPercent;
    if (_pdfViewKey.currentContext != null) {
      final RenderBox? renderBox = _pdfViewKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        newXPercent = newX / renderBox.size.width;
        newYPercent = newY / renderBox.size.height;
      }
    }
    
    // Create updated point with new position (preserve screen dimensions and fontSize)
    final updatedPoint = InspectionPoint(
      name: currentPoint.name,
      value: currentPoint.value,
      result: currentPoint.result,
      comments: currentPoint.comments,
      posX: newX,
      posY: newY,
      screenWidth: currentPoint.screenWidth,
      screenHeight: currentPoint.screenHeight,
      fontSize: currentPoint.fontSize,
      posXPercent: newXPercent ?? currentPoint.posXPercent,
      posYPercent: newYPercent ?? currentPoint.posYPercent,
    );
    
    // Create a copy of the inspection points with the updated point
    final updatedInspectionPoints = Map<String, InspectionPoint>.from(pagePieceMark.inspectionPoints);
    updatedInspectionPoints[pointName] = updatedPoint;
    
    // Create an updated piece mark
    final updatedPieceMark = PieceMark(
      id: pagePieceMark.id,
      pageNumber: pagePieceMark.pageNumber,
      pieceMarkId: pagePieceMark.pieceMarkId,
      description: pagePieceMark.description,
      inspectionPoints: updatedInspectionPoints,
      inspectorSignature: pagePieceMark.inspectorSignature,
      signatureX: pagePieceMark.signatureX,
      signatureY: pagePieceMark.signatureY,
      inspectorId: pagePieceMark.inspectorId,
      inspectionDate: pagePieceMark.inspectionDate,
      status: pagePieceMark.status,
      annotations: pagePieceMark.annotations,
      remarks: pagePieceMark.remarks,
    );
    
    // Update the state
    setState(() {
      // Find and replace the piece mark in the list
      final index = _pieceMarks.indexWhere((pm) => pm.pageNumber == pageNumber);
      if (index >= 0) {
        _pieceMarks[index] = updatedPieceMark;
      } else {
        _pieceMarks.add(updatedPieceMark);
      }
      
      // Update current piece mark if it's the same one
      if (_currentPieceMark?.pageNumber == pageNumber) {
        _currentPieceMark = updatedPieceMark;
      }
    });
    
    // Save to Firestore
    _savePieceMarkData(updatedPieceMark);
  }

  /// Updates the font size of an inspection point
  void _updateInspectionPointFontSize(String pointName, int pageNumber, double newFontSize) {
    final pagePieceMark = _pieceMarks.firstWhere(
      (pm) => pm.pageNumber == pageNumber,
      orElse: () => PieceMark(
        id: '',
        pageNumber: pageNumber,
        pieceMarkId: 'PM-$pageNumber',
        description: 'Inspection for page $pageNumber',
        inspectionPoints: {},
        status: 'pending',
      ),
    );
    
    if (pagePieceMark.id.isEmpty || !pagePieceMark.inspectionPoints.containsKey(pointName)) {
      return;
    }
    
    final currentPoint = pagePieceMark.inspectionPoints[pointName]!;
    
    final updatedPoint = InspectionPoint(
      name: currentPoint.name,
      value: currentPoint.value,
      result: currentPoint.result,
      comments: currentPoint.comments,
      posX: currentPoint.posX,
      posY: currentPoint.posY,
      screenWidth: currentPoint.screenWidth,
      screenHeight: currentPoint.screenHeight,
      fontSize: newFontSize,
      posXPercent: currentPoint.posXPercent,
      posYPercent: currentPoint.posYPercent,
    );
    
    final updatedInspectionPoints = Map<String, InspectionPoint>.from(pagePieceMark.inspectionPoints);
    updatedInspectionPoints[pointName] = updatedPoint;
    
    final updatedPieceMark = PieceMark(
      id: pagePieceMark.id,
      pageNumber: pagePieceMark.pageNumber,
      pieceMarkId: pagePieceMark.pieceMarkId,
      description: pagePieceMark.description,
      inspectionPoints: updatedInspectionPoints,
      inspectorSignature: pagePieceMark.inspectorSignature,
      signatureX: pagePieceMark.signatureX,
      signatureY: pagePieceMark.signatureY,
      inspectorId: pagePieceMark.inspectorId,
      inspectionDate: pagePieceMark.inspectionDate,
      status: pagePieceMark.status,
      annotations: pagePieceMark.annotations,
      remarks: pagePieceMark.remarks,
    );
    
    setState(() {
      final index = _pieceMarks.indexWhere((pm) => pm.pageNumber == pageNumber);
      if (index >= 0) {
        _pieceMarks[index] = updatedPieceMark;
      }
      if (_currentPieceMark?.pageNumber == pageNumber) {
        _currentPieceMark = updatedPieceMark;
      }
    });
    
    _savePieceMarkData(updatedPieceMark);
  }

  /// Shows a dialog to edit existing text
  void _showEditTextDialog(String pointName, int pageNumber, InspectionPoint point) {
    String editedValue = point.value;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: TextField(
            controller: TextEditingController(text: point.value),
            decoration: const InputDecoration(
              labelText: 'Text',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              editedValue = value;
            },
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editedValue.isNotEmpty) {
                  _updateInspectionPointValue(pointName, pageNumber, editedValue);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Updates the value/text of an inspection point
  void _updateInspectionPointValue(String pointName, int pageNumber, String newValue) {
    final pagePieceMark = _pieceMarks.firstWhere(
      (pm) => pm.pageNumber == pageNumber,
      orElse: () => PieceMark(
        id: '',
        pageNumber: pageNumber,
        pieceMarkId: 'PM-$pageNumber',
        description: 'Inspection for page $pageNumber',
        inspectionPoints: {},
        status: 'pending',
      ),
    );
    
    if (pagePieceMark.id.isEmpty || !pagePieceMark.inspectionPoints.containsKey(pointName)) {
      return;
    }
    
    final currentPoint = pagePieceMark.inspectionPoints[pointName]!;
    
    final updatedPoint = InspectionPoint(
      name: currentPoint.name,
      value: newValue,
      result: currentPoint.result,
      comments: currentPoint.comments,
      posX: currentPoint.posX,
      posY: currentPoint.posY,
      screenWidth: currentPoint.screenWidth,
      screenHeight: currentPoint.screenHeight,
      fontSize: currentPoint.fontSize,
      posXPercent: currentPoint.posXPercent,
      posYPercent: currentPoint.posYPercent,
    );
    
    final updatedInspectionPoints = Map<String, InspectionPoint>.from(pagePieceMark.inspectionPoints);
    updatedInspectionPoints[pointName] = updatedPoint;
    
    final updatedPieceMark = PieceMark(
      id: pagePieceMark.id,
      pageNumber: pagePieceMark.pageNumber,
      pieceMarkId: pagePieceMark.pieceMarkId,
      description: pagePieceMark.description,
      inspectionPoints: updatedInspectionPoints,
      inspectorSignature: pagePieceMark.inspectorSignature,
      signatureX: pagePieceMark.signatureX,
      signatureY: pagePieceMark.signatureY,
      inspectorId: pagePieceMark.inspectorId,
      inspectionDate: pagePieceMark.inspectionDate,
      status: pagePieceMark.status,
      annotations: pagePieceMark.annotations,
      remarks: pagePieceMark.remarks,
    );
    
    setState(() {
      final index = _pieceMarks.indexWhere((pm) => pm.pageNumber == pageNumber);
      if (index >= 0) {
        _pieceMarks[index] = updatedPieceMark;
      }
      if (_currentPieceMark?.pageNumber == pageNumber) {
        _currentPieceMark = updatedPieceMark;
      }
    });
    
    _savePieceMarkData(updatedPieceMark);
  }

  /// Deletes a text box from the current page
  void _deleteTextBox(String pointName, int pageNumber) {
    // Find the piece mark for this page
    final pagePieceMark = _pieceMarks.firstWhere(
      (pm) => pm.pageNumber == pageNumber,
      orElse: () => PieceMark(
        id: '',
        pageNumber: pageNumber,
        pieceMarkId: '',
        description: '',
        inspectionPoints: {},
        status: 'pending',
      ),
    );
    
    if (pagePieceMark.inspectionPoints.isEmpty) return;
    
    // Create a copy of inspection points without the deleted one
    final updatedInspectionPoints = Map<String, InspectionPoint>.from(pagePieceMark.inspectionPoints);
    updatedInspectionPoints.remove(pointName);
    
    // Create updated piece mark
    final updatedPieceMark = PieceMark(
      id: pagePieceMark.id,
      pageNumber: pagePieceMark.pageNumber,
      pieceMarkId: pagePieceMark.pieceMarkId,
      description: pagePieceMark.description,
      inspectionPoints: updatedInspectionPoints,
      inspectorSignature: pagePieceMark.inspectorSignature,
      signatureX: pagePieceMark.signatureX,
      signatureY: pagePieceMark.signatureY,
      inspectorId: pagePieceMark.inspectorId,
      inspectionDate: pagePieceMark.inspectionDate,
      status: pagePieceMark.status,
      annotations: pagePieceMark.annotations,
      remarks: pagePieceMark.remarks,
    );
    
    setState(() {
      final index = _pieceMarks.indexWhere((pm) => pm.pageNumber == pageNumber);
      if (index >= 0) {
        _pieceMarks[index] = updatedPieceMark;
      }
      if (_currentPieceMark?.pageNumber == pageNumber) {
        _currentPieceMark = updatedPieceMark;
      }
    });
    
    _savePieceMarkData(updatedPieceMark);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text box deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _showSignatureDialog(String recordName, String recordValue, String recordResult) async {
    // Create a signature controller using the signature package
    final signatureController = SignatureController(
      penStrokeWidth: 3.0,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Signature'),
          content: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Signature(
                      controller: signatureController,
                      width: 300,
                      height: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        signatureController.clear();
                      },
                      tooltip: 'Clear Signature',
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                signatureController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (signatureController.isNotEmpty) {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Dialog(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 20),
                              Text('Processing signature...'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  
                  try {
                    // Export signature as PNG bytes
                    final signatureBytes = await signatureController.toPngBytes();
                    
                    // Close loading dialog
                    Navigator.of(context).pop();
                    
                    if (signatureBytes != null) {
                      // Convert bytes to base64 string for storage
                      final base64Signature = base64Encode(signatureBytes);
                      
                      // Add the record with signature
                      if (_lastTapPosition != null) {
                        _addInspectionRecord(
                          recordName, 
                          recordValue, 
                          recordResult, 
                          base64Signature,
                          _lastTapPosition!.dx,
                          _lastTapPosition!.dy,
                        );
                      } else {
                        // If no position is specified, use a default position
                        _addInspectionRecord(
                          recordName, 
                          recordValue, 
                          recordResult, 
                          base64Signature,
                          100.0,  // Default X position
                          100.0,  // Default Y position
                        );
                      }
                      
                      // Display success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signature added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    // Close loading dialog if still open
                    Navigator.of(context).pop();
                    
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error processing signature: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                } else {
                  // No signature provided
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a signature')),
                  );
                  return;
                }
                
                signatureController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Adds a new inspection record to the current piece mark
  void _addInspectionRecord(String name, String value, String result, String signature, [double? posX, double? posY]) {
    if (_currentPieceMark == null) {
      // Create a new piece mark if none exists
      _createOrUpdatePieceMark(_currentPage + 1);
    }
    
    if (_currentPieceMark != null) {
      // Get widget dimensions and calculate percentage-based position
      double? screenWidth;
      double? screenHeight;
      double? posXPercent;
      double? posYPercent;
      
      if (_pdfViewKey.currentContext != null && posX != null && posY != null) {
        final RenderBox? renderBox = _pdfViewKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          screenWidth = renderBox.size.width;
          screenHeight = renderBox.size.height;
          
          // Calculate percentage positions (0.0 to 1.0)
          posXPercent = posX / screenWidth;
          posYPercent = posY / screenHeight;
          
          print('📍 NEW APPROACH: Tap at ($posX, $posY) | Widget ($screenWidth, $screenHeight) | Percent ($posXPercent, $posYPercent)');
        }
      }
      
      // Create a copy of the current inspection points
      final updatedInspectionPoints = Map<String, InspectionPoint>.from(_currentPieceMark!.inspectionPoints);
      
      // Add or update the inspection point with BOTH absolute and percentage positions
      updatedInspectionPoints[name] = InspectionPoint(
        name: name,
        value: value,
        result: result,
        comments: '', // Add empty comments
        posX: posX,
        posY: posY,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        posXPercent: posXPercent,
        posYPercent: posYPercent,
      );
      
      // Determine if all inspection points are completed (pass or fail)
      bool allCompleted = true;
      for (var point in updatedInspectionPoints.values) {
        if (point.result != 'pass' && point.result != 'fail') {
          allCompleted = false;
          break;
        }
      }
      
      // Set status to completed if all inspection points are done
      String status = allCompleted ? 'completed' : 'in_progress';
      
      // Create an updated piece mark
      final updatedPieceMark = PieceMark(
        id: _currentPieceMark!.id,
        pageNumber: _currentPieceMark!.pageNumber,
        pieceMarkId: _currentPieceMark!.pieceMarkId,
        description: _currentPieceMark!.description,
        inspectionPoints: updatedInspectionPoints,
        inspectorSignature: signature.isNotEmpty ? signature : _currentPieceMark!.inspectorSignature,
        signatureX: signature.isNotEmpty ? 50.0 : _currentPieceMark!.signatureX,
        signatureY: signature.isNotEmpty ? 50.0 : _currentPieceMark!.signatureY,
        inspectorId: _currentPieceMark!.inspectorId,
        inspectionDate: DateTime.now(),
        status: status,
        annotations: _currentPieceMark!.annotations,
        remarks: _currentPieceMark!.remarks,
      );
      
      // Update the current piece mark in the state
      setState(() {
        _currentPieceMark = updatedPieceMark;
        
        // Also update in the piece marks list
        final index = _pieceMarks.indexWhere((pm) => pm.pageNumber == updatedPieceMark.pageNumber);
        if (index >= 0) {
          _pieceMarks[index] = updatedPieceMark;
        } else {
          _pieceMarks.add(updatedPieceMark);
        }
        
        // Debug: Print signature info
        if (signature.isNotEmpty) {
          print('✅ SIGNATURE SAVED! Length: ${updatedPieceMark.inspectorSignature.length}');
          print('✅ Current PieceMark signature: ${_currentPieceMark!.inspectorSignature.length}');
        }
      });
      
      // Save the updated piece mark
      _savePieceMarkData(updatedPieceMark);
      
      // Clear the last tap position
      _lastTapPosition = null;
      
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inspection record added'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Helper method to build signature widget
  Widget _buildSignatureWidget(String base64Signature) {
    Uint8List? signatureBytes;
    
    try {
      signatureBytes = base64Decode(base64Signature);
    } catch (e) {
      print('Error decoding signature: $e');
      return const SizedBox.shrink();
    }
    
    if (signatureBytes == null || signatureBytes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: 200,
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: Image.memory(
              signatureBytes,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.drag_indicator,
                  size: 12,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the inspection progress bar
  Widget _buildInspectionProgressBar() {
    // Calculate progress based on completed inspection points
    double progress = 0.0;
    int totalPoints = 0;
    int completedPoints = 0;
    
    for (var pieceMark in _pieceMarks) {
      for (var point in pieceMark.inspectionPoints.values) {
        totalPoints++;
        if (point.result == 'pass' || point.result == 'fail') {
          completedPoints++;
        }
      }
    }
    
    if (totalPoints > 0) {
      progress = completedPoints / totalPoints;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inspection Progress: ${(progress * 100).toStringAsFixed(0)}%'),
              Text('$completedPoints/$totalPoints points'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.3 ? Colors.red : (progress < 0.7 ? Colors.orange : Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Save all changes before disposing
    _saveAllChanges();
    super.dispose();
  }

  /// Save all changes to Firestore
  Future<void> _saveAllChanges() async {
    try {
      // If there's no route card yet, create one
      if (_routeCard == null) {
        final newRouteCard = RouteCard(
          id: '',
          workOrderId: widget.workOrderId,
          totalPages: _totalPages,
          pieceMarks: _pieceMarks,
          lastUpdated: DateTime.now(),
          status: 'in_progress',
        );
        
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('route_cards')
            .add(newRouteCard.toFirestore());
      } else {
        // Update existing route card
        final updatedRouteCard = RouteCard(
          id: _routeCard!.id,
          workOrderId: widget.workOrderId,
          totalPages: _totalPages,
          pieceMarks: _pieceMarks,
          lastUpdated: DateTime.now(),
          status: _routeCard!.status,
        );
        
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('route_cards')
            .doc(_routeCard!.id)
            .update(updatedRouteCard.toFirestore());
      }
      
      print('All changes saved successfully');
    } catch (e) {
      print('Error saving all changes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteCard Viewer'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          // Save button
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Saving...'),
                        ],
                      ),
                    ),
                  );
                },
              );
              
              // Save all changes
              await _saveAllChanges();
              
              // Close loading dialog
              Navigator.of(context).pop();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All changes saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Save All Changes',
          ),
          IconButton(
            icon: Icon(_isTextBoxMode ? Icons.check : Icons.text_fields),
            onPressed: () {
              setState(() {
                _isTextBoxMode = !_isTextBoxMode;
                _isAnnotationMode = false;
                _isInspectionMode = false;
              });
            },
            tooltip: _isTextBoxMode ? 'Exit Text Box Mode' : 'Add Text Boxes',
            color: _isTextBoxMode ? Colors.green : Colors.white,
          ),
          IconButton(
            icon: Icon(_isInspectionMode ? Icons.close : Icons.edit_note),
            onPressed: () {
              setState(() {
                _isInspectionMode = !_isInspectionMode;
                _isAnnotationMode = false;
                _isTextBoxMode = false;
                if (_isInspectionMode) {
                  _createOrUpdatePieceMark(_currentPage + 1);
                }
              });
            },
            tooltip: _isInspectionMode ? 'Close Inspection Form' : 'Open Inspection Form',
          ),
          IconButton(
            icon: Icon(_isAnnotationMode ? Icons.close : Icons.draw),
            onPressed: () {
              setState(() {
                _isAnnotationMode = !_isAnnotationMode;
                _isInspectionMode = false;
                _isTextBoxMode = false;
              });
            },
            tooltip: _isAnnotationMode ? 'Close Annotation Tools' : 'Open Annotation Tools',
          ),
          // Mark as Complete button - Uploads PDF and completes inspection
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: _markInspectionComplete,
            tooltip: 'Mark as Complete & Upload to Server',
          ),
          // Download PDF to device
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdfToDevice,
            tooltip: 'Download PDF to Device',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      key: _pdfViewKey,
                      child: Stack(
                        children: [
                          // PDF View
                          PDFView(
                            filePath: _pdfFile!.path,
                            enableSwipe: true,
                            swipeHorizontal: true,
                            autoSpacing: true,
                            pageFling: true,
                            pageSnap: true,
                            defaultPage: _currentPage,
                            fitPolicy: FitPolicy.BOTH,
                            preventLinkNavigation: false,
                            fitEachPage: true,
                            onRender: (pages) {
                              setState(() {
                                _totalPages = pages!;
                              });
                            },
                            onError: (error) {
                              setState(() {
                                _errorMessage = error.toString();
                              });
                            },
                            onPageError: (page, error) {
                              setState(() {
                                _errorMessage = 'Error on page $page: $error';
                              });
                            },
                            onPageChanged: (int? page, int? total) {
                              if (page != null) {
                                setState(() {
                                  _currentPage = page;
                                });
                                
                                if (_isInspectionMode) {
                                  _createOrUpdatePieceMark(page + 1);
                                }
                              }
                            },
                            onViewCreated: (PDFViewController pdfViewController) {
                              _controller.complete(pdfViewController);
                              setState(() {
                                _pdfController = pdfViewController;
                              });
                            },
                          ),
                          
                          // Transparent overlay for adding text boxes (only in text box mode)
                          if (_isTextBoxMode)
                            Positioned.fill(
                              child: GestureDetector(
                                onTapDown: (details) {
                                  // Store tap position for text box placement
                                  setState(() {
                                    _lastTapPosition = Offset(
                                      details.localPosition.dx + _positionOffsetX,
                                      details.localPosition.dy + _positionOffsetY,
                                    );
                                  });
                                  
                                  // Debug: Log tap position and widget size
                                  if (_pdfViewKey.currentContext != null) {
                                    final RenderBox? renderBox = _pdfViewKey.currentContext!.findRenderObject() as RenderBox?;
                                    if (renderBox != null) {
                                      print('📍 TAP: Position=(${details.localPosition.dx.toStringAsFixed(1)}, ${details.localPosition.dy.toStringAsFixed(1)}) | Widget Size=(${renderBox.size.width.toStringAsFixed(1)}, ${renderBox.size.height.toStringAsFixed(1)})');
                                    }
                                  }
                                  
                                  // Show dialog to add text box
                                  _showAddRecordDialog();
                                },
                                // Transparent container to capture taps
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                            
                          // Display inspection records as positionable text boxes
                          // Find the piece mark for the current page
                          ...(() {
                            // Find the piece mark for the current page
                            final currentPageNumber = _currentPage + 1;
                            final currentPagePieceMark = _pieceMarks.firstWhere(
                              (pm) => pm.pageNumber == currentPageNumber,
                              orElse: () => PieceMark(
                                id: '',
                                pageNumber: currentPageNumber,
                                pieceMarkId: '',
                                description: '',
                                inspectionPoints: {},
                                status: 'pending',
                              ),
                            );
                            
                            // If there are no inspection points for this page, return empty list
                            if (currentPagePieceMark.inspectionPoints.isEmpty) {
                              return <Widget>[];
                            }
                            
                            // Map inspection points to positioned widgets
                            return currentPagePieceMark.inspectionPoints.entries.map((entry) {
                              final point = entry.value;
                              
                              // Skip records without position data
                              if (point.posX == null || point.posY == null) {
                                return const SizedBox.shrink();
                              }
                              
                              // Skip "Signature" placeholder text if there's an actual signature image
                              if (currentPagePieceMark.inspectorSignature.isNotEmpty && 
                                  (point.value == 'Signature' || point.value.toLowerCase() == 'signature')) {
                                return const SizedBox.shrink();
                              }
                              
                              // Calculate display position
                              double displayX = point.posX ?? 0;
                              double displayY = point.posY ?? 0;
                              
                              // Use percentage-based position if available (more accurate)
                              if (point.posXPercent != null && point.posYPercent != null && _pdfViewKey.currentContext != null) {
                                final RenderBox? renderBox = _pdfViewKey.currentContext!.findRenderObject() as RenderBox?;
                                if (renderBox != null) {
                                  displayX = point.posXPercent! * renderBox.size.width;
                                  displayY = point.posYPercent! * renderBox.size.height;
                                }
                              }
                              
                              // Make text draggable, editable, and resizable (only in text box mode)
                              return Positioned(
                                left: displayX,
                                top: displayY,
                                child: GestureDetector(
                                  // Tap to edit (only in text box mode)
                                  onTap: _isTextBoxMode ? () {
                                    _showEditTextDialog(entry.key, currentPageNumber, point);
                                  } : null,
                                  // Use scale gestures for both dragging and pinching (only in text box mode)
                                  onScaleStart: _isTextBoxMode ? (details) {
                                    setState(() {
                                      _isDragging = true;
                                      _draggedPointName = entry.key;
                                      _draggedPageNumber = currentPageNumber;
                                      _dragOffset = Offset.zero;
                                      _initialFontSize = point.fontSize;
                                    });
                                  } : null,
                                  onScaleUpdate: _isTextBoxMode ? (details) {
                                    if (_draggedPointName == entry.key) {
                                      setState(() {
                                        // If scale is close to 1.0, it's a drag (move)
                                        if ((details.scale - 1.0).abs() < 0.1) {
                                          _dragOffset = _dragOffset + details.focalPointDelta;
                                        } else {
                                          // Otherwise, it's a pinch (resize)
                                          _isDragging = false;
                                          double newFontSize = (_initialFontSize * details.scale).clamp(8.0, 48.0);
                                          _updateInspectionPointFontSize(
                                            entry.key,
                                            currentPageNumber,
                                            newFontSize,
                                          );
                                        }
                                      });
                                    }
                                  } : null,
                                  onScaleEnd: _isTextBoxMode ? (details) {
                                    if (_isDragging && _draggedPointName == entry.key) {
                                      final newX = point.posX! + _dragOffset.dx;
                                      final newY = point.posY! + _dragOffset.dy;
                                      _updateInspectionPointPosition(
                                        entry.key,
                                        currentPageNumber,
                                        newX,
                                        newY,
                                      );
                                    }
                                    setState(() {
                                      _isDragging = false;
                                      _draggedPointName = null;
                                      _draggedPageNumber = null;
                                      _dragOffset = Offset.zero;
                                    });
                                  } : null,
                                  child: Transform.translate(
                                    offset: (_isDragging && _draggedPointName == entry.key) ? _dragOffset : Offset.zero,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            point.value,
                                            style: TextStyle(
                                              fontSize: point.fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (_isTextBoxMode) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.edit,
                                              size: point.fontSize * 0.8,
                                              color: Colors.blue[600],
                                            ),
                                            const SizedBox(width: 2),
                                            GestureDetector(
                                              onTap: () {
                                                _deleteTextBox(entry.key, currentPageNumber);
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: point.fontSize * 0.8,
                                                color: Colors.red[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList();
                          })(),
                          
                          // Display signature image if exists
                          ...(() {
                            if (_currentPieceMark != null && _currentPieceMark!.inspectorSignature.isNotEmpty) {
                              print('📝 DISPLAYING SIGNATURE: Length = ${_currentPieceMark!.inspectorSignature.length}');
                              
                              // Use saved position or default
                              final double signatureX = _currentPieceMark!.signatureX ?? 50;
                              final double signatureY = _currentPieceMark!.signatureY ?? 50;
                              
                              return [
                                Positioned(
                                  left: signatureX,
                                  top: signatureY,
                                  child: GestureDetector(
                                    onPanStart: (details) {
                                      setState(() {
                                        _isDragging = true;
                                        _draggedPointName = 'signature';
                                        _draggedPageNumber = _currentPage + 1;
                                        _dragOffset = Offset.zero;
                                      });
                                    },
                                    onPanUpdate: (details) {
                                      if (_isDragging && _draggedPointName == 'signature') {
                                        setState(() {
                                          _dragOffset = _dragOffset + details.delta;
                                        });
                                      }
                                    },
                                    onPanEnd: (details) {
                                      if (_isDragging && _draggedPointName == 'signature') {
                                        // Calculate new position
                                        final newX = signatureX + _dragOffset.dx;
                                        final newY = signatureY + _dragOffset.dy;
                                        
                                        // Update signature position
                                        _updateSignaturePosition(newX, newY);
                                        
                                        // Reset drag state
                                        setState(() {
                                          _isDragging = false;
                                          _draggedPointName = null;
                                          _draggedPageNumber = null;
                                          _dragOffset = Offset.zero;
                                        });
                                      }
                                    },
                                    child: Transform.translate(
                                      offset: (_isDragging && _draggedPointName == 'signature') ? _dragOffset : Offset.zero,
                                      child: _buildSignatureWidget(_currentPieceMark!.inspectorSignature),
                                    ),
                                  ),
                                ),
                              ];
                            }
                            print('❌ NO SIGNATURE TO DISPLAY: currentPieceMark = ${_currentPieceMark?.id}, signature length = ${_currentPieceMark?.inspectorSignature.length ?? 0}');
                            return <Widget>[];
                          })(),
                          
                          // Annotation tools when in annotation mode
                          if (_isAnnotationMode)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: PDFAnnotationTools(
                                onAnnotationAdded: (String annotationData) {
                                  // Save annotation data
                                  if (_currentPieceMark != null) {
                                    final updatedAnnotations = List<String>.from(_currentPieceMark!.annotations);
                                    updatedAnnotations.add(annotationData);
                                    
                                    final updatedPieceMark = PieceMark(
                                      id: _currentPieceMark!.id,
                                      pageNumber: _currentPieceMark!.pageNumber,
                                      pieceMarkId: _currentPieceMark!.pieceMarkId,
                                      description: _currentPieceMark!.description,
                                      inspectionPoints: _currentPieceMark!.inspectionPoints,
                                      inspectorSignature: _currentPieceMark!.inspectorSignature,
                                      signatureX: _currentPieceMark!.signatureX,
                                      signatureY: _currentPieceMark!.signatureY,
                                      inspectorId: _currentPieceMark!.inspectorId,
                                      inspectionDate: _currentPieceMark!.inspectionDate,
                                      status: _currentPieceMark!.status,
                                      annotations: updatedAnnotations,
                                      remarks: _currentPieceMark!.remarks,
                                    );
                                    
                                    _savePieceMarkData(updatedPieceMark);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Progress bar showing inspection completion
                    _buildInspectionProgressBar(),
                    
                    // Page navigation with status indicators
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          // Page indicator and status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Page ${_currentPage + 1} of $_totalPages',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: _currentPage > 0
                                        ? () {
                                            _pdfController?.setPage(_currentPage - 1);
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: _currentPage < _totalPages - 1
                                        ? () {
                                            _pdfController?.setPage(_currentPage + 1);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Page status indicators
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_totalPages, (index) {
                                // Find piece mark for this page if it exists
                                final pagePieceMark = _pieceMarks.firstWhere(
                                  (pm) => pm.pageNumber == index + 1,
                                  orElse: () => PieceMark(
                                    id: '',
                                    pageNumber: index + 1,
                                    pieceMarkId: '',
                                    description: '',
                                    inspectionPoints: {},
                                    status: 'pending',
                                  ),
                                );
                                
                                // Determine status color
                                Color statusColor;
                                IconData statusIcon;
                                
                                if (pagePieceMark.status == 'completed') {
                                  statusColor = Colors.green;
                                  statusIcon = Icons.check_circle;
                                } else if (pagePieceMark.status == 'in_progress') {
                                  statusColor = Colors.orange;
                                  statusIcon = Icons.pending;
                                } else if (pagePieceMark.inspectionPoints.isNotEmpty) {
                                  statusColor = Colors.blue;
                                  statusIcon = Icons.edit;
                                } else {
                                  statusColor = Colors.grey;
                                  statusIcon = Icons.circle_outlined;
                                }
                                
                                return GestureDetector(
                                  onTap: () {
                                    _pdfController?.setPage(index);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _currentPage == index ? Colors.blue.shade100 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(statusIcon, color: statusColor, size: 16),
                                        SizedBox(height: 4),
                                        Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: _currentPage == index ? FontWeight.bold : FontWeight.normal,
                                            color: _currentPage == index ? Colors.blue.shade800 : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Using the signature package instead of custom implementation
