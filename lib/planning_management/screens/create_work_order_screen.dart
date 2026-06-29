import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../shared/services/http_file_upload_service.dart';

import '../models/planning_work_order_model.dart';
import '../services/pdf_splitting_service.dart';
import '../../login/user_provider.dart';

class CreateWorkOrderScreen extends StatefulWidget {
  const CreateWorkOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateWorkOrderScreen> createState() => _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends State<CreateWorkOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isProcessingPdf = false;
  File? _pdfFile;
  String _fileName = '';
  // Removed unused field: _processingProgress
  int _totalPages = 0;
  
  final TextEditingController _workOrderNumberController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  
  @override
  void dispose() {
    _workOrderNumberController.dispose();
    _projectNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          // Default to 1 page, will be updated during processing
          _totalPages = 1;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessingPdf = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }
  
  // Page count is now automatically determined during PDF processing

  Future<void> _createWorkOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_pdfFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a RouteCard PDF file')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get current user
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final createdBy = userProvider.email;

        // Create Work Order doc reference
        final workOrderRef = FirebaseFirestore.instance.collection('work_orders').doc();
        
        // Upload PDF to custom server
        final uniqueFileName = '${workOrderRef.id}_${DateTime.now().millisecondsSinceEpoch}_$_fileName';
        String pdfUrl;
        
        try {
          pdfUrl = await HttpFileUploadService.uploadPdf(_pdfFile!, uniqueFileName);
          print('✅ RouteCard uploaded to server: $pdfUrl');
        } catch (e) {
          // If upload fails, show error and stop
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload PDF: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Process PDF splitting
        setState(() {
          _isProcessingPdf = true;
        });
        
        List<String> inspectionSheetUrls = [];
        try {
          // Split PDF into individual pages using local file path
          inspectionSheetUrls = await PdfSplittingService.splitAndUploadPdf(
            _pdfFile!.path,
            workOrderRef.id,
          );
          
          // Update total pages based on the actual processing result
          if (inspectionSheetUrls.isNotEmpty) {
            _totalPages = inspectionSheetUrls.length;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing PDF: $e')),
          );
          // Continue with the work order creation even if PDF splitting fails
          // The PDF will still be available for viewing
        } finally {
          setState(() {
            _isProcessingPdf = false;
          });
        }
        
        // Create a work order that matches the Inspection Module's model
        // We'll create a Map directly instead of using PlanningWorkOrder to ensure compatibility
        final workOrderData = {
          'workOrderNumber': _workOrderNumberController.text,
          'projectName': _projectNameController.text,
          'description': _itemDescriptionController.text, // Map itemDescription to description for compatibility
          'createdBy': createdBy,
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'dueDate': Timestamp.fromDate(_dueDate),
          'status': 'pending',
          'routeCardUrl': pdfUrl,
          'assignedInspectors': [], // Empty list to match Inspection Module's model
          'metadata': {
            'fileName': _fileName,
            'uploadDate': DateTime.now().toIso8601String(),
            'inspectionStatus': 'ready_for_inspection',
            'pdfType': 'routecard',
            'fileType': 'pdf',
            'quantity': int.parse(_quantityController.text),
            'totalPages': _totalPages,
            'inspectionSheetUrls': inspectionSheetUrls,
            'inspectionModule': {
              'enabled': true,
              'sheets': List.generate(_totalPages, (index) => {
                'pageNumber': index + 1,
                'status': 'pending',
                'inspectionPoints': [],
                'remarks': '',
              }).toList(),
            },
          },
        };

        await workOrderRef.set(workOrderData);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work Order created successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isProcessingPdf = false;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating Work Order: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Work Order'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _isProcessingPdf
                        ? 'Processing PDF... This may take a few moments.'
                        : 'Creating Work Order...',
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _workOrderNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Work Order Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a work order number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _projectNameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Item Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an item description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_dueDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'RouteCard PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isProcessingPdf ? null : _pickPDF,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.upload_file,
                              color: Colors.blue[900],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _isProcessingPdf
                                  ? const Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Processing PDF...'),
                                      ],
                                    )
                                  : Text(
                                      _pdfFile != null
                                          ? 'Selected: $_fileName ($_totalPages pages)'
                                          : 'Select RouteCard PDF',
                                      style: TextStyle(
                                        color: _pdfFile != null
                                            ? Colors.black
                                            : Colors.grey[600],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_pdfFile != null && _totalPages > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'The PDF will be automatically split into $_totalPages individual inspection sheets.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessingPdf ? null : _createWorkOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Work Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
