import 'package:application_v1/planning_management/screens/work_order_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../inspection_management/screens/work_order_list_screen.dart';
import '../../login/user_provider.dart';
import '../models/planning_work_order_model.dart';
import 'create_work_order_screen.dart';
import 'work_order_details_screen.dart';
import 'planning_pending_approvals_screen.dart';

class PlanningDashboardScreen extends StatefulWidget {
  const PlanningDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PlanningDashboardScreen> createState() => _PlanningDashboardScreenState();
}

class _PlanningDashboardScreenState extends State<PlanningDashboardScreen> {
  String _filterStatus = 'all';
  final List<String> _statusFilters = ['all', 'draft', 'pending', 'in_progress', 'completed', 'rejected'];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning Department'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,

      ),
      body:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${userProvider.firstName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage work orders from this dashboard.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ),

          const SizedBox(height: 24),

          // Main actions section
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildActionCard(
                context,
                'View Work Orders',
                Icons.assignment,
                Colors.blue,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WorkOrderListScreenview()),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Completed Inspections',
                Icons.check_circle,
                Colors.green,
                    () {
                  // Navigate to filtered work orders for this inspector
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkOrderListScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Pending Approvals',
                Icons.pending_actions,
                Colors.orange,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlanningPendingApprovalsScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Reports',
                Icons.bar_chart,
                Colors.purple,
                    () {
                  // Navigate to reports (to be implemented)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reports feature coming soon')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Information section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Planning Management',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This module allows you to digitally manage the post-Work orders. '
                        'You can view ROUTECARD PDF files, check inspection results, '
                        'and sign off on completed PM.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For help using this module, please contact the IT department.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ]
    ),
    ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateWorkOrderScreen()),
          );
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      ),

    );
  }


}

class WorkOrderListItem extends StatelessWidget {
  final PlanningWorkOrder workOrder;
  final VoidCallback onTap;

  const WorkOrderListItem({
    Key? key,
    required this.workOrder,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
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
                      'WO #${workOrder.workOrderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildStatusChip(workOrder.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workOrder.projectName,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Item: ${workOrder.itemDescription}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quantity: ${workOrder.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_formatDate(workOrder.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Due: ${_formatDate(workOrder.dueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDueDateNear(workOrder.dueDate) ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.description, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${workOrder.totalPages} inspection sheets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      case 'admin_approved':
        chipColor = Colors.teal;
        break;
      case 'rejected':
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
        StringExtension(status.replaceAll('_', ' ')).capitalize(),
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isDueDateNear(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= 3 && difference >= 0; // Due date is within 3 days
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ) {
  return Card(
    elevation: 2,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}