import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../login/user_provider.dart';
import '../../inspection_management/screens/route_card_viewer_screen.dart';
import '../services/pdf_splitting_service.dart';

class PlanningPendingApprovalsScreen extends StatefulWidget {
  const PlanningPendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<PlanningPendingApprovalsScreen> createState() => _PlanningPendingApprovalsScreenState();
}

class _PlanningPendingApprovalsScreenState extends State<PlanningPendingApprovalsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingApprovals = [];

  @override
  void initState() {
    super.initState();
    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the same logic as AdminApprovalScreen but scoped for PPC
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

  Future<void> _downloadFullPdf(Map<String, dynamic> approval) async {
    try {
      final workOrderId = approval['id'] as String;

      // Reload work order to get latest metadata
      final workOrderDoc = await FirebaseFirestore.instance
          .collection('work_orders')
          .doc(workOrderId)
          .get();

      final data = workOrderDoc.data() as Map<String, dynamic>?;

      int pageCount = 0;
      if (data != null &&
          data['metadata'] != null &&
          data['metadata']['inspectionModule'] != null &&
          data['metadata']['inspectionModule']['sheets'] != null) {
        final sheets = data['metadata']['inspectionModule']['sheets'] as List<dynamic>;
        pageCount = sheets.length;
      }

      if (pageCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No inspection sheets available to merge for this work order')),
        );
        return;
      }

      // Build dummy page paths list; PdfSplittingService will pull real inspection data from Firestore
      final List<String> pagePaths =
          List<String>.generate(pageCount, (index) => 'page_${index + 1}_$workOrderId.pdf');

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

      final mergedPath = await PdfSplittingService.mergePdfPages(pagePaths, workOrderId);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Full PDF saved at: $mergedPath'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating full PDF: $e')),
      );
    }
  }

  Future<void> _approveInspection(String workOrderId) async {
    try {
      // Update work order status to approved/completed
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
        'message': 'Your inspection for ${workOrder['workOrderNumber']} has been approved by PPC',
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
      // Update work order status back to in_progress
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
        'message': 'Your inspection for ${workOrder['workOrderNumber']} needs revision (PPC)',
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
    final userProvider = Provider.of<UserProvider>(context);
    final isPpcDepartment = userProvider.department_id == '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PPC Pending Approvals'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingApprovals,
          ),
        ],
      ),
      body: !isPpcDepartment
          ? const Center(
              child: Text('You do not have permission to view this screen'),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingApprovals.isEmpty
                  ? const Center(child: Text('No inspections pending PPC approval'))
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
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  onPressed: () => _downloadFullPdf(approval),
                                  tooltip: 'Download / View Full PDF',
                                ),
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
                                  onPressed: () => _approveInspection(approval['id']),
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _rejectInspection(approval['id']),
                                  tooltip: 'Return for Revision',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
