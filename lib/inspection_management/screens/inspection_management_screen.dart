import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'work_order_list_screen.dart';
import '../../login/user_provider.dart';

class InspectionManagementScreen extends StatelessWidget {
  const InspectionManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Management'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
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
                        'Manage your inspection tasks and work orders from this dashboard.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
              
              // Action cards
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
                        MaterialPageRoute(builder: (context) => const WorkOrderListScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    'My Inspections',
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
                      // Navigate to pending approvals
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
                        'About Inspection Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This module allows you to digitally manage the post-fabrication inspection process. '
                        'You can view and annotate ROUTECARD PDF files, enter inspection results, '
                        'and sign off on completed inspections.',
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
            ],
          ),
        ),
      ),
    );
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
}
