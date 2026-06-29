import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../login/user_provider.dart';
import 'planning_dashboard_screen.dart';
import '../../inspection_management/screens/inspection_management_screen.dart';

class PlanningMainScreen extends StatefulWidget {
  const PlanningMainScreen({Key? key}) : super(key: key);

  @override
  State<PlanningMainScreen> createState() => _PlanningMainScreenState();
}

class _PlanningMainScreenState extends State<PlanningMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPlanningDepartment = userProvider.department_id == "Planning";
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning & Inspection'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Planning', icon: Icon(Icons.assignment)),
            Tab(text: 'Inspection', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Planning Tab

          
          // Inspection Tab
          InspectionManagementScreen(),
        ],
      ),
    );
  }
}
