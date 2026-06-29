import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/planning_work_order_model.dart';
import '../../login/user_provider.dart';
import 'inspection_sheet_viewer_screen.dart';

class WorkOrderDetailsScreen extends StatefulWidget {
  final String workOrderId;

  const WorkOrderDetailsScreen({
    Key? key,
    required this.workOrderId,
  }) : super(key: key);

  @override
  State<WorkOrderDetailsScreen> createState() => _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends State<WorkOrderDetailsScreen> {
  bool _isLoading = true;
  PlanningWorkOrder? _workOrder;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWorkOrderData();
  }

  Future<void> _loadWorkOrderData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load work order data
      final workOrderDoc = await FirebaseFirestore.instance
          .collection('planning_work_orders')
          .doc(widget.workOrderId)
          .get();

      if (!workOrderDoc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Work order not found';
        });
        return;
      }

      _workOrder = PlanningWorkOrder.fromFirestore(workOrderDoc);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading work order: $e';
      });
    }
  }

  Future<void> _updateWorkOrderStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('planning_work_orders')
          .doc(widget.workOrderId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Work order status updated to $newStatus')),
      );

      // Refresh the data
      _loadWorkOrderData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPlanningDepartment = userProvider.department_id == "Planning";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Order Details'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          if (_workOrder != null && isPlanningDepartment)
            PopupMenuButton<String>(
              onSelected: _updateWorkOrderStatus,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'draft',
                  child: Text('Mark as Draft'),
                ),
                const PopupMenuItem<String>(
                  value: 'pending',
                  child: Text('Mark as Pending'),
                ),
                const PopupMenuItem<String>(
                  value: 'in_progress',
                  child: Text('Mark as In Progress'),
                ),
                const PopupMenuItem<String>(
                  value: 'completed',
                  child: Text('Mark as Completed'),
                ),
                const PopupMenuItem<String>(
                  value: 'rejected',
                  child: Text('Mark as Rejected'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _workOrder == null
                  ? const Center(child: Text('Work order not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWorkOrderHeader(),
                          const SizedBox(height: 24),
                          _buildWorkOrderDetails(),
                          const SizedBox(height: 24),
                          _buildInspectionSheetsList(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildWorkOrderHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'WO #${_workOrder!.workOrderNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(_workOrder!.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _workOrder!.projectName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOrderDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Item Description', _workOrder!.itemDescription),
            _buildDetailRow('Quantity', _workOrder!.quantity.toString()),
            _buildDetailRow('Created By', _workOrder!.createdBy),
            _buildDetailRow(
              'Created Date',
              DateFormat('yyyy-MM-dd HH:mm').format(_workOrder!.createdAt),
            ),
            _buildDetailRow(
              'Due Date',
              DateFormat('yyyy-MM-dd').format(_workOrder!.dueDate),
            ),
            _buildDetailRow('Total Pages', _workOrder!.totalPages.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'N/A' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionSheetsList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inspection Sheets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_workOrder!.inspectionSheetUrls.isEmpty)
              const Text('No inspection sheets available')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workOrder!.inspectionSheetUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text('Page ${index + 1}'),
                    subtitle: Text('Piece Mark ${index + 1}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InspectionSheetViewerScreen(
                            workOrderId: _workOrder!.id,
                            pdfUrl: _workOrder!.inspectionSheetUrls[index],
                            pageNumber: index + 1,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Open the full RouteCard PDF
                    // This would typically navigate to a PDF viewer
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening full RouteCard PDF...')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('View Full PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Share the work order
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing functionality coming soon...')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    
    switch (status) {
      case 'draft':
        chipColor = Colors.grey;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'in_progress':
        chipColor = Colors.blue;
        break;
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
