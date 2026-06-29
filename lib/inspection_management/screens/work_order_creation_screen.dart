import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../models/work_order_model.dart';
import '../../login/user_provider.dart';
import '../../shared/services/http_file_upload_service.dart';

class WorkOrderCreationScreen extends StatefulWidget {
  const WorkOrderCreationScreen({Key? key}) : super(key: key);

  @override
  State<WorkOrderCreationScreen> createState() => _WorkOrderCreationScreenState();
}

class _WorkOrderCreationScreenState extends State<WorkOrderCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _pdfFile;
  String _fileName = '';
  final TextEditingController _workOrderNumberController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  final List<String> _assignedInspectors = [];
  
  // List of available inspectors (would be fetched from Firestore in a real app)
  final List<Map<String, dynamic>> _availableInspectors = [
    {'id': 'inspector1', 'name': 'Inspector 1'},
    {'id': 'inspector2', 'name': 'Inspector 2'},
    {'id': 'inspector3', 'name': 'Inspector 3'},
  ];

  @override
  void dispose() {
    _workOrderNumberController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
          _fileName = path.basename(_pdfFile!.path);
        });
      }
    } catch (e) {
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

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

        // Create Work Order in Firestore
        final workOrderRef = FirebaseFirestore.instance.collection('work_orders').doc();

        // Upload PDF to custom server
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${workOrderRef.id}_${timestamp}_$_fileName';
        String downloadUrl;
        
        try {
          downloadUrl = await HttpFileUploadService.uploadPdf(_pdfFile!, uniqueFileName);
          print('✅ RouteCard uploaded to server: $downloadUrl');
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
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        final workOrder = WorkOrder(
          id: workOrderRef.id,
          workOrderNumber: _workOrderNumberController.text,
          projectName: _projectNameController.text,
          description: _descriptionController.text,
          createdBy: createdBy,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          status: 'pending',
          routeCardUrl: downloadUrl,
          assignedInspectors: _assignedInspectors,
          metadata: {
            'fileName': _fileName,
            'uploadDate': DateTime.now().toIso8601String(),
          },
        );

        await workOrderRef.set(workOrder.toFirestore());

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work Order created successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
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
          ? const Center(child: CircularProgressIndicator())
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
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
                      'Assign Inspectors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _availableInspectors.map((inspector) {
                        final isSelected = _assignedInspectors.contains(inspector['id']);
                        return FilterChip(
                          label: Text(inspector['name']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _assignedInspectors.add(inspector['id']);
                              } else {
                                _assignedInspectors.remove(inspector['id']);
                              }
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue[100],
                        );
                      }).toList(),
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
                      onTap: _pickPDF,
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
                              child: Text(
                                _pdfFile != null
                                    ? 'Selected: $_fileName'
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
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createWorkOrder,
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
