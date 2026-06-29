import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../login/user_provider.dart';

class InspectionSheetViewerScreen extends StatefulWidget {
  final String workOrderId;
  final String pdfUrl;
  final int pageNumber;

  const InspectionSheetViewerScreen({
    Key? key,
    required this.workOrderId,
    required this.pdfUrl,
    required this.pageNumber,
  }) : super(key: key);

  @override
  State<InspectionSheetViewerScreen> createState() => _InspectionSheetViewerScreenState();
}

class _InspectionSheetViewerScreenState extends State<InspectionSheetViewerScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  bool _isLoading = true;
  String _errorMessage = '';
  File? _pdfFile;
  
  // Inspection data
  final TextEditingController _remarksController = TextEditingController();
  String _inspectionStatus = 'pending';
  Map<String, dynamic> _inspectionData = {};
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _loadPdf();
    _loadInspectionData();
  }
  
  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Download the PDF file
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to download PDF: ${response.statusCode}';
        });
        return;
      }

      // Get temporary directory to store the PDF
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/inspection_${widget.workOrderId}_${widget.pageNumber}.pdf';
      final file = File(filePath);
      
      // Write the PDF to the file
      await file.writeAsBytes(response.bodyBytes);
      
      setState(() {
        _pdfFile = file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading PDF: $e';
      });
    }
  }
  
  Future<void> _loadInspectionData() async {
    try {
      final inspectionDoc = await FirebaseFirestore.instance
          .collection('inspection_data')
          .doc(widget.workOrderId)
          .collection('pages')
          .doc(widget.pageNumber.toString())
          .get();
          
      if (inspectionDoc.exists) {
        final data = inspectionDoc.data() as Map<String, dynamic>;
        setState(() {
          _inspectionData = data;
          _inspectionStatus = data['status'] ?? 'pending';
          _remarksController.text = data['remarks'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading inspection data: $e');
    }
  }
  
  Future<void> _saveInspectionData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Create inspection data
      final data = {
        'status': _inspectionStatus,
        'remarks': _remarksController.text,
        'inspectedBy': userProvider.email,
        'inspectedAt': FieldValue.serverTimestamp(),
        'pageNumber': widget.pageNumber,
        'workOrderId': widget.workOrderId,
      };
      
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('inspection_data')
          .doc(widget.workOrderId)
          .collection('pages')
          .doc(widget.pageNumber.toString())
          .set(data, SetOptions(merge: true));
          
      setState(() {
        _inspectionData = data;
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspection data saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving inspection data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspection Sheet ${widget.pageNumber}'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            tooltip: _isEditing ? 'Cancel Editing' : 'Edit Inspection Data',
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
                      child: PDFView(
                        filePath: _pdfFile!.path,
                        enableSwipe: false,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: false,
                        pageSnap: false,
                        fitPolicy: FitPolicy.BOTH,
                        preventLinkNavigation: false,
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
                        onViewCreated: (PDFViewController pdfViewController) {
                          _controller.complete(pdfViewController);
                        },
                      ),
                    ),
                    
                    // Inspection data section
                    _isEditing
                        ? _buildInspectionForm()
                        : _buildInspectionDataView(),
                  ],
                ),
    );
  }
  
  Widget _buildInspectionDataView() {
    final inspectedBy = _inspectionData['inspectedBy'] ?? '';
    final inspectedAt = _inspectionData['inspectedAt'] != null
        ? ((_inspectionData['inspectedAt'] as Timestamp).toDate().toString())
        : 'Not inspected yet';
        
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${_inspectionStatus.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_inspectionStatus),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Remarks: ${_remarksController.text.isEmpty ? 'None' : _remarksController.text}'),
          const SizedBox(height: 8),
          Text('Inspected by: $inspectedBy'),
          Text('Inspected at: $inspectedAt'),
        ],
      ),
    );
  }
  
  Widget _buildInspectionForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inspection Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _inspectionStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'passed', child: Text('Passed')),
                    DropdownMenuItem(value: 'failed', child: Text('Failed')),
                    DropdownMenuItem(value: 'waived', child: Text('Waived')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _inspectionStatus = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Remarks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter any remarks or observations',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveInspectionData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'passed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'waived':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
