import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/route_card_model.dart';
import '../../login/user_provider.dart';
import 'signature_pad.dart';

class InspectionForm extends StatefulWidget {
  final PieceMark pieceMark;
  final Function(PieceMark) onSave;

  const InspectionForm({
    Key? key,
    required this.pieceMark,
    required this.onSave,
  }) : super(key: key);

  @override
  State<InspectionForm> createState() => _InspectionFormState();
}

class _InspectionFormState extends State<InspectionForm> {
  late PieceMark _pieceMark;
  final TextEditingController _remarksController = TextEditingController();
  final Map<String, TextEditingController> _valueControllers = {};
  final Map<String, String> _results = {};
  bool _isSignatureVisible = false;
  String _signatureData = '';

  @override
  void initState() {
    super.initState();
    _pieceMark = widget.pieceMark;
    _remarksController.text = _pieceMark.remarks;
    
    // Initialize inspection points if empty
    if (_pieceMark.inspectionPoints.isEmpty) {
      _initializeDefaultInspectionPoints();
    } else {
      // Initialize controllers for existing inspection points
      for (var entry in _pieceMark.inspectionPoints.entries) {
        _valueControllers[entry.key] = TextEditingController(text: entry.value.value);
        _results[entry.key] = entry.value.result;
      }
    }
  }

  void _initializeDefaultInspectionPoints() {
    // Default inspection points based on typical quality checks
    final defaultPoints = {
      'dimensions': 'Dimensions Check',
      'surface': 'Surface Quality',
      'welds': 'Weld Quality',
      'coating': 'Coating Thickness',
      'alignment': 'Alignment Check',
    };
    
    for (var entry in defaultPoints.entries) {
      _valueControllers[entry.key] = TextEditingController();
      _results[entry.key] = 'na';
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    for (var controller in _valueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveInspectionData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Create updated inspection points
    final Map<String, InspectionPoint> updatedInspectionPoints = {};
    for (var entry in _valueControllers.entries) {
      updatedInspectionPoints[entry.key] = InspectionPoint(
        name: entry.key,
        value: entry.value.text,
        result: _results[entry.key] ?? 'na',
      );
    }
    
    // Determine page status based on inspection results
    // This is the status for this individual page
    String pageStatus = 'pending';
    if (updatedInspectionPoints.isNotEmpty) {
      bool hasFailures = updatedInspectionPoints.values.any((point) => point.result == 'fail');
      bool allPassed = updatedInspectionPoints.values.every((point) => point.result == 'pass');
      
      if (hasFailures) {
        pageStatus = 'failed';
      } else if (allPassed) {
        pageStatus = 'completed'; // Individual page can be marked as completed
      }
    }
    
    // Create updated piece mark
    final updatedPieceMark = PieceMark(
      id: _pieceMark.id,
      pageNumber: _pieceMark.pageNumber,
      pieceMarkId: _pieceMark.pieceMarkId,
      description: _pieceMark.description,
      inspectionPoints: updatedInspectionPoints,
      inspectorSignature: _signatureData.isNotEmpty ? _signatureData : _pieceMark.inspectorSignature,
      inspectorId: userProvider.email,
      inspectionDate: DateTime.now(),
      status: pageStatus,
      annotations: _pieceMark.annotations,
      remarks: _remarksController.text,
    );
    
    // Save the updated piece mark
    widget.onSave(updatedPieceMark);
    
    // Hide signature pad if visible
    if (_isSignatureVisible) {
      setState(() {
        _isSignatureVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with piece mark info
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Piece Mark: ${_pieceMark.pieceMarkId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                _buildStatusChip(_pieceMark.status),
              ],
            ),
          ),
          
          // Inspection points
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Inspection Points',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          
          ..._valueControllers.entries.map((entry) => _buildInspectionPointRow(entry.key)),
          
          // Add inspection point button
          TextButton.icon(
            onPressed: _showAddInspectionPointDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Inspection Point'),
          ),
          
          const Divider(),
          
          // Remarks
          const Text(
            'Remarks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextField(
            controller: _remarksController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter any additional remarks',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Signature section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inspector Signature',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isSignatureVisible = !_isSignatureVisible;
                  });
                },
                icon: Icon(_isSignatureVisible ? Icons.close : Icons.draw),
                label: Text(_isSignatureVisible ? 'Cancel' : 'Sign'),
              ),
            ],
          ),
          
          if (_isSignatureVisible)
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: SignaturePad(
                onSignatureCapture: (String signatureData) {
                  setState(() {
                    _signatureData = signatureData;
                    _isSignatureVisible = false;
                  });
                },
              ),
            )
          else if (_signatureData.isNotEmpty || _pieceMark.inspectorSignature.isNotEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _signatureData.isNotEmpty
                  ? Image.memory(
                      base64Decode(_signatureData.split(',').last),
                      fit: BoxFit.contain,
                    )
                  : _pieceMark.inspectorSignature.isNotEmpty
                      ? Image.memory(
                          base64Decode(_pieceMark.inspectorSignature.split(',').last),
                          fit: BoxFit.contain,
                        )
                      : const Center(child: Text('No signature')),
            ),
          
          const SizedBox(height: 16),
          
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveInspectionData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Save Inspection Data'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionPointRow(String key) {
    final controller = _valueControllers[key]!;
    final result = _results[key] ?? 'na';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Inspection point name
          Expanded(
            flex: 2,
            child: Text(
              key.capitalize(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          
          // Value input
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter value',
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Result selection
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: result,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  _results[key] = newValue!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'pass', child: Text('Pass')),
                DropdownMenuItem(value: 'fail', child: Text('Fail')),
                DropdownMenuItem(value: 'na', child: Text('N/A')),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _valueControllers.remove(key);
                _results.remove(key);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddInspectionPointDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Inspection Point'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Enter inspection point name',
              labelText: 'Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _valueControllers[name] = TextEditingController();
                    _results[name] = 'na';
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayStatus = status;
    
    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'passed':
      case 'completed':
        chipColor = Colors.green;
        displayStatus = 'completed';
        break;
      case 'failed':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        displayStatus.capitalize(),
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
