import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/work_order_model.dart';
import '../models/route_card_model.dart';
import '../../login/user_provider.dart';
import 'route_card_viewer_screen.dart';
import '../../planning_management/services/pdf_splitting_service.dart';

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
  WorkOrder? _workOrder;
  RouteCard? _routeCard;
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
          .collection('work_orders')
          .doc(widget.workOrderId)
          .get();

      if (!workOrderDoc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Work order not found';
        });
        return;
      }

      _workOrder = WorkOrder.fromFirestore(workOrderDoc);

      // Load route card data
      final routeCardQuery = await FirebaseFirestore.instance
          .collection('route_cards')
          .where('workOrderId', isEqualTo: widget.workOrderId)
          .limit(1)
          .get();

      if (routeCardQuery.docs.isNotEmpty) {
        _routeCard = RouteCard.fromFirestore(routeCardQuery.docs.first);
      }

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
          .collection('work_orders')
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
  
  /// Shows a dialog to confirm marking the inspection as complete
  Future<void> _showCompletionConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Completion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to mark this inspection as complete?'),
                SizedBox(height: 10),
                Text(
                  'This will finalize the inspection and send it to the manager for review.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Mark as Complete'),
              onPressed: () {
                Navigator.of(context).pop();
                _markInspectionComplete();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// Marks the inspection as complete and sends to admin for approval
  Future<void> _markInspectionComplete() async {
    try {
      // Get current user info
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final inspectorId = userProvider.email;
      final inspectorName = userProvider.firstName ;
      
      // Update work order status to 'pending_approval' instead of 'completed'
      await FirebaseFirestore.instance
          .collection('work_orders')
          .doc(widget.workOrderId)
          .update({
        'status': 'pending_approval',
        'metadata.inspectionStatus': 'pending_approval',
        'metadata.submittedBy': inspectorId,
        'metadata.submittedByName': inspectorName,
        'metadata.submittedAt': FieldValue.serverTimestamp(),
        'metadata.needsAdminReview': true,
      });
      
      // Update route card status if it exists
      if (_routeCard != null) {
        await FirebaseFirestore.instance
            .collection('route_cards')
            .doc(_routeCard!.id)
            .update({
          'status': 'pending_approval',
          'lastUpdated': FieldValue.serverTimestamp(),
          'submittedBy': inspectorId,
          'submittedByName': inspectorName,
        });
      }
      
      // Create notification for admin
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'type': 'inspection_approval',
        'workOrderId': widget.workOrderId,
        'workOrderNumber': _workOrder?.workOrderNumber ?? '',
        'message': 'Inspection completed by ${inspectorName} and needs approval',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'targetRole': 'PPC',
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection submitted for admin approval!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the data
      _loadWorkOrderData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting inspection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isInspector = userProvider.department_id == "PPC" ||
                        userProvider.department_id == "PPC";
    final isPlanner = userProvider.department_id == "PPC";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Order Details'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          if (_workOrder != null && (isPlanner || isInspector))
            PopupMenuButton<String>(
              onSelected: _updateWorkOrderStatus,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                if (isPlanner)
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
                          _buildAssignedInspectors(),
                          const SizedBox(height: 24),
                          _buildRouteCardSection(),
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
                    _workOrder!.workOrderNumber,
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
            _buildDetailRow('Description', _workOrder!.description),
            _buildDetailRow('Created By', _workOrder!.createdBy),
            _buildDetailRow(
              'Created Date',
              DateFormat('yyyy-MM-dd HH:mm').format(_workOrder!.createdAt),
            ),
            _buildDetailRow(
              'Due Date',
              DateFormat('yyyy-MM-dd').format(_workOrder!.dueDate),
            ),
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
            width: 100,
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

  Widget _buildAssignedInspectors() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Inspectors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _workOrder!.assignedInspectors.isEmpty
                ? const Text('No inspectors assigned')
                : Column(
                    children: _workOrder!.assignedInspectors
                        .map((inspector) => ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(inspector), // In a real app, you would fetch the inspector's name
                              subtitle: const Text('Inspector'),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCardSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RouteCard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_routeCard != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Total Pages', _routeCard!.totalPages.toString()),
                  _buildDetailRow(
                    'Last Updated',
                    DateFormat('yyyy-MM-dd HH:mm').format(_routeCard!.lastUpdated),
                  ),
                  _buildDetailRow('Status', _routeCard!.status),
                ],
              )
            else
              const Text('RouteCard data not yet processed'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteCardViewerScreen(
                        workOrderId: widget.workOrderId,
                        pdfUrl: _workOrder!.routeCardUrl,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View RouteCard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    // Determine page count from metadata.inspectionModule.sheets if available
                    int pageCount = 0;
                    if (_workOrder!.metadata != null &&
                        _workOrder!.metadata['inspectionModule'] != null &&
                        _workOrder!.metadata['inspectionModule']['sheets'] != null) {
                      final sheets = _workOrder!.metadata['inspectionModule']['sheets'] as List<dynamic>;
                      pageCount = sheets.length;
                    }

                    if (pageCount == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No inspection sheets available to merge')),
                      );
                      return;
                    }

                    // Build dummy page paths list; PdfSplittingService will pull real inspection data from Firestore
                    final List<String> pagePaths = List<String>.generate(
                      pageCount,
                      (index) => 'page_${index + 1}_${widget.workOrderId}.pdf',
                    );

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return const Dialog(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 20),
                                Text('Preparing full PDF...'),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    final mergedPath = await PdfSplittingService.mergePdfPages(
                      pagePaths,
                      widget.workOrderId,
                    );

                    Navigator.of(context).pop();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteCardViewerScreen(
                          workOrderId: widget.workOrderId,
                          pdfUrl: mergedPath,
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).maybePop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error generating full PDF: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Download Full PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            // Always show the completion button unless status is already 'completed'
            if (_workOrder!.status != 'completed') ...[  
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompletionConfirmationDialog(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Inspection as Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    
    switch (status) {
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
