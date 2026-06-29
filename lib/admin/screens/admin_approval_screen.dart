import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../login/user_provider.dart';
import '../../inspection_management/models/route_card_model.dart';
import '../../inspection_management/screens/route_card_viewer_screen.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({Key? key}) : super(key: key);

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingApprovals = [];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPendingApprovals();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPendingApprovals() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Query work orders that need admin approval
      final querySnapshot = await FirebaseFirestore.instance
          .collection('work_orders')
          .where('status', isEqualTo: 'pending_approval')
          .orderBy('metadata.submittedAt', descending: true)
          .get();
      
      final approvals = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'workOrderNumber': data['workOrderNumber'] ?? 'Unknown',
          'projectName': data['projectName'] ?? 'Unknown',
          'submittedBy': data['metadata']?['submittedByName'] ?? 'Unknown',
          'submittedAt': data['metadata']?['submittedAt'] != null 
              ? (data['metadata']['submittedAt'] as Timestamp).toDate() 
              : DateTime.now(),
          'routeCardUrl': data['routeCardUrl'] ?? '',
          'data': data,
        };
      }).toList();
      
      setState(() {
        _pendingApprovals = approvals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading approvals: $e')),
      );
    }
  }
  
  Future<void> _approveInspection(String workOrderId) async {
    try {
      // Update work order status to approved
      await FirebaseFirestore.instance
          .collection('work_orders')
          .doc(workOrderId)
          .update({
        'status': 'completed',
        'metadata.inspectionStatus': 'completed',
        'metadata.approvedBy': Provider.of<UserProvider>(context, listen: false).email,
        'metadata.approvedAt': FieldValue.serverTimestamp(),
        'metadata.needsAdminReview': false,
      });
      
      // Update route card status
      final routeCardQuery = await FirebaseFirestore.instance
          .collection('route_cards')
          .where('workOrderId', isEqualTo: workOrderId)
          .limit(1)
          .get();
      
      if (routeCardQuery.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('route_cards')
            .doc(routeCardQuery.docs.first.id)
            .update({
          'status': 'completed',
          'approvedBy': Provider.of<UserProvider>(context, listen: false).email,
          'approvedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Create notification for inspector
      final workOrder = _pendingApprovals.firstWhere((wo) => wo['id'] == workOrderId);
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'type': 'inspection_approved',
        'workOrderId': workOrderId,
        'workOrderNumber': workOrder['workOrderNumber'],
        'message': 'Your inspection for ${workOrder['workOrderNumber']} has been approved',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'targetUser': workOrder['data']['metadata']?['submittedBy'] ?? '',
      });
      
      // Refresh the list
      _loadPendingApprovals();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving inspection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _rejectInspection(String workOrderId) async {
    try {
      // Update work order status to rejected
      await FirebaseFirestore.instance
          .collection('work_orders')
          .doc(workOrderId)
          .update({
        'status': 'in_progress',
        'metadata.inspectionStatus': 'rejected',
        'metadata.rejectedBy': Provider.of<UserProvider>(context, listen: false).email,
        'metadata.rejectedAt': FieldValue.serverTimestamp(),
        'metadata.needsAdminReview': false,
      });
      
      // Update route card status
      final routeCardQuery = await FirebaseFirestore.instance
          .collection('route_cards')
          .where('workOrderId', isEqualTo: workOrderId)
          .limit(1)
          .get();
      
      if (routeCardQuery.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('route_cards')
            .doc(routeCardQuery.docs.first.id)
            .update({
          'status': 'in_progress',
          'rejectedBy': Provider.of<UserProvider>(context, listen: false).email,
          'rejectedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Create notification for inspector
      final workOrder = _pendingApprovals.firstWhere((wo) => wo['id'] == workOrderId);
      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
        'type': 'inspection_rejected',
        'workOrderId': workOrderId,
        'workOrderNumber': workOrder['workOrderNumber'],
        'message': 'Your inspection for ${workOrder['workOrderNumber']} needs revision',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'targetUser': workOrder['data']['metadata']?['submittedBy'] ?? '',
      });
      
      // Refresh the list
      _loadPendingApprovals();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection returned for revision'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting inspection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Approval Dashboard'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Approvals'),
            Tab(text: 'Approval History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingApprovals,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Approvals Tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingApprovals.isEmpty
                  ? const Center(child: Text('No pending approvals'))
                  : ListView.builder(
                      itemCount: _pendingApprovals.length,
                      itemBuilder: (context, index) {
                        final approval = _pendingApprovals[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              approval['workOrderNumber'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(approval['projectName']),
                                Text(
                                  'Submitted by: ${approval['submittedBy']} on ${DateFormat('yyyy-MM-dd HH:mm').format(approval['submittedAt'])}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RouteCardViewerScreen(
                                          workOrderId: approval['id'],
                                          pdfUrl: approval['routeCardUrl'],
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: 'View Inspection',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _showApprovalConfirmationDialog(approval['id']),
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _showRejectionDialog(approval['id']),
                                  tooltip: 'Return for Revision',
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
          
          // Approval History Tab
          const Center(child: Text('Approval history will be shown here')),
        ],
      ),
    );
  }
  
  Future<void> _showApprovalConfirmationDialog(String workOrderId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Approval'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to approve this inspection?'),
                SizedBox(height: 10),
                Text(
                  'This will mark the inspection as completed and notify the inspector.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
                _approveInspection(workOrderId);
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _showRejectionDialog(String workOrderId) async {
    String rejectionReason = '';
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return for Revision'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please provide a reason for returning this inspection:'),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter reason for revision',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    rejectionReason = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Return for Revision'),
              onPressed: () {
                if (rejectionReason.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                
                // Update the work order with rejection reason
                FirebaseFirestore.instance
                    .collection('work_orders')
                    .doc(workOrderId)
                    .update({
                  'metadata.rejectionReason': rejectionReason,
                }).then((_) {
                  _rejectInspection(workOrderId);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
