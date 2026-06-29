import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login/user_provider.dart';
import 'screens/admin_approval_screen.dart';

class AdminMenuItem extends StatelessWidget {
  const AdminMenuItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.department_id == "Admin" || 
                    userProvider.department_id == "Management";
    
    // Only show admin menu for admin users
    if (!isAdmin) {
      return const SizedBox.shrink();
    }
    
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminApprovalScreen(),
            ),
          );
        },
        child: Container(
          height: screenHeight * 0.25,
          width: screenWidth * 0.40,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: const BorderRadius.all(Radius.circular(50.0)),
          ),
          child: Stack(
            children: [
              // Centered text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue[900],
                      size: screenHeight * 0.05,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Admin Dashboard",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.022,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Approvals & Management",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: screenHeight * 0.016,
                      ),
                    ),
                    // Badge showing pending approvals
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('work_orders')
                            .where('status', isEqualTo: 'pending_approval')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final count = snapshot.data!.docs.length;
                            return Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return const Text(
                            "0",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
