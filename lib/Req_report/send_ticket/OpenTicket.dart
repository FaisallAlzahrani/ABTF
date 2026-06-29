import 'dart:convert';
import 'dart:math';
import 'package:application_v1/home/Operations_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'package:http/http.dart' as http;
import '../../Notifications System/google_auth_services.dart';
import '../../login/user_provider.dart';
import '../../utils/connectivity_monitor.dart';
import '../../utils/connectivity_service.dart';
import '../../utils/ticket_storage_service.dart';
import '../../utils/ticket_sync_service.dart';


class OpenTicketPage extends StatefulWidget {
  const OpenTicketPage({Key? key}) : super(key: key);

  @override
  _OpenTicketPageState createState() => _OpenTicketPageState();
}

class _OpenTicketPageState extends State<OpenTicketPage> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  TextEditingController factoryController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController equipmentController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController troubleDescriptionController = TextEditingController();

  String? selectedPriority = 'Urgent/Code'; // Default selected priority
  String? reportedBy;
  String? pending = 'pending';
  String? staus1 = 'NotApprove';
  String currentDateTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());
  String? ApprovedBy = 'Approvedby';
  String? status4 = 'NotApprovedByOperation';
  String? OperationApproved = 'NotApproved';
  String? manager = '18288';
  String? RecevedBy = "";

  // Requisition number is now managed by Firebase
  String requisitionNumber = '';

  bool isSubmitting = false; // ✅ New variable to prevent double taps

  @override
  void initState() {
    super.initState();
    reportedBy = Provider.of<UserProvider>(context, listen: false).firstName;
    _getRequisitionNumber();
    
    // Check for pending offline tickets and sync them if online
    _checkAndSyncPendingTickets();
    
    // Start connectivity monitoring if there are pending tickets
    TicketStorageService.hasPendingTickets().then((hasPendingTickets) {
      if (hasPendingTickets) {
        ConnectivityMonitor.startMonitoring(context);
      }
    });
  }
  
  @override
  void dispose() {
    // Stop connectivity monitoring when the page is closed
    ConnectivityMonitor.stopMonitoring();
    super.dispose();
  }
  
  // Check for pending tickets and sync them if online
  Future<void> _checkAndSyncPendingTickets() async {
    // Check if there are any pending tickets
    bool hasPendingTickets = await TicketStorageService.hasPendingTickets();
    
    if (hasPendingTickets) {
      // Check for internet connectivity
      bool isConnected = await ConnectivityService.isConnected();
      
      if (isConnected) {
        // If online, sync pending tickets
        await TicketSyncService.syncPendingTickets(context);
      } else {
        // If offline, show notification that there are pending tickets
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You have pending tickets that will be submitted when internet is available."),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 10),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Operations_screen()),
        );
      }
    }
  }

  Future<void> _getRequisitionNumber() async {
    DocumentReference requisitionRef = FirebaseFirestore.instance.collection('settings').doc('requisition_number');
    DocumentSnapshot snapshot = await requisitionRef.get();
    int requisitionNum = 11561;
    if (snapshot.exists) {
      requisitionNum = snapshot['lastRequisitionNumber'] ?? 11561;
    }
    setState(() {
      requisitionNumber = requisitionNum.toString();
    });
    requisitionNum++;
    await requisitionRef.set({
      'lastRequisitionNumber': requisitionNum,
    });
  }

  Future<void> notifyMaintenanceDepartment({
    required String Notificationtitle,
    required String Notificationtext,
    required String requisitionNumber,
  }) async {
    const String maintenanceDepartmentId = "Maintenance";

    final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Notification_system')
        .where('department_id', isEqualTo: maintenanceDepartmentId)
        .get();

    final List<String> fcmTokens = usersSnapshot.docs
        .map((doc) => doc['fcm_token'] as String?)
        .where((token) => token != null && token.isNotEmpty)
        .cast<String>()
        .toList();

    if (fcmTokens.isNotEmpty) {
      try {
        final GoogleAuthService authService = GoogleAuthService();
        final String bearerToken = await authService.getOAuth2BearerToken();

        for (String token in fcmTokens) {
          final response = await http.post(
            Uri.parse('https://fcm.googleapis.com/v1/projects/towerapp-fec08/messages:send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $bearerToken',
            },
            body: jsonEncode({
              'message': {
                'token': token,
                'notification': {
                  'title': Notificationtitle,
                  'body': Notificationtext,
                },
                'data': {
                  'requisition_number': requisitionNumber,
                },
              },
            }),
          );

          if (response.statusCode != 200) {
            print('Error sending notification to $token: ${response.body}');
          }
        }
      } catch (e) {
        print('Error generating or using token: $e');
      }
    }
  }


  // Function to submit the ticket data to Firebase
  Future<void> submitTicket({final String? requisitionNumber1}) async {
    if (isSubmitting) return;
    setState(() {
      isSubmitting = true;
    });

    // Create ticket data map
    Map<String, dynamic> ticketData = {
      'Requisition Number': requisitionNumber,
      'Factory': factoryController.text,
      'Section': sectionController.text,
      'machineEquipment': equipmentController.text,
      'Serial Number': int.parse(serialNumberController.text),
      'TroubleDescription': troubleDescriptionController.text,
      'Priority': selectedPriority,
      'Reported_By': reportedBy,
      'Date_Time': currentDateTime,
      'status': pending,
      'status1': staus1,
      'status3': ApprovedBy,
      'Data_Time3': currentDateTime,
      'Operation': OperationApproved,
      'Data_Time4': currentDateTime,
      'status4': status4,
      'manager': manager,
      'RecevedBy': RecevedBy,
      'created_offline': false,
    };

    // Check for internet connectivity
    bool isConnected = await ConnectivityService.isConnected();

    try {
      if (isConnected) {
        // Online - Submit directly to Firebase
        final requstionformaintservices = FirebaseFirestore.instance.collection('Tickets').doc(requisitionNumber);
        await requstionformaintservices.set(ticketData, SetOptions(merge: true));

        // Send notification
        await notifyMaintenanceDepartment(
          Notificationtitle: 'New Ticket Opened',
          Notificationtext: 'A new ticket (#$requisitionNumber) has been created.',
          requisitionNumber: requisitionNumber,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ticket submitted successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Operations_screen()),
        );
      } else {
        // Offline - Save to local storage
        ticketData['created_offline'] = true;
        await TicketStorageService.saveOfflineTicket(ticketData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ticket saved offline. Will be submitted when internet connection is available."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 12),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Operations_screen()),
        );
      }

      // Clear form fields regardless of online/offline status
      factoryController.clear();
      sectionController.clear();
      equipmentController.clear();
      serialNumberController.clear();
      troubleDescriptionController.clear();

      // Get new requisition number for next ticket
      if (isConnected) {
        await _getRequisitionNumber();
      } else {
        // If offline, increment locally
        setState(() {
          int currentReqNum = int.parse(requisitionNumber);
          requisitionNumber = (currentReqNum + 1).toString();
        });
      }
    } catch (e) {
      print("Error submitting ticket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit ticket: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    const brandColor = Color(0xFF104164);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Open Ticket',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth.clamp(0, 820);
          final double padding = (maxWidth * 0.05).clamp(16.0, 24.0);
          final bool wide = maxWidth >= 700;

          InputDecoration fieldDecoration({required String label, IconData? icon}) {
            return InputDecoration(
              labelText: label,
              prefixIcon: icon == null ? null : Icon(icon, color: brandColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: brandColor.withValues(alpha: 0.18)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: brandColor.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: brandColor, width: 2),
              ),
            );
          }

          Widget sectionCard({required Widget child}) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    sectionCard(
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                            ),
                            child: const Icon(Icons.confirmation_number_outlined, color: brandColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requisition Number',
                                  style: const TextStyle(
                                    color: brandColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  requisitionNumber.isEmpty ? '—' : requisitionNumber,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assest/images/r2.png',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ticket Details',
                            style: TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (wide)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: factoryController,
                                    decoration: fieldDecoration(label: 'Factory', icon: Icons.factory_outlined),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: sectionController,
                                    decoration: fieldDecoration(label: 'Section', icon: Icons.account_tree_outlined),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            TextFormField(
                              controller: factoryController,
                              decoration: fieldDecoration(label: 'Factory', icon: Icons.factory_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: sectionController,
                              decoration: fieldDecoration(label: 'Section', icon: Icons.account_tree_outlined),
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (wide)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: equipmentController,
                                    decoration: fieldDecoration(label: 'Machine Equipment', icon: Icons.precision_manufacturing_outlined),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: serialNumberController,
                                    decoration: fieldDecoration(label: 'Serial Number', icon: Icons.numbers_outlined),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            TextFormField(
                              controller: equipmentController,
                              decoration: fieldDecoration(label: 'Machine Equipment', icon: Icons.precision_manufacturing_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: serialNumberController,
                              decoration: fieldDecoration(label: 'Serial Number', icon: Icons.numbers_outlined),
                            ),
                          ],
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: troubleDescriptionController,
                            maxLines: 5,
                            decoration: fieldDecoration(label: 'Trouble Description', icon: Icons.report_problem_outlined),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedPriority,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPriority = newValue;
                              });
                            },
                            items: [
                              'Urgent/Code',
                              'Stop/Operation',
                              'Rush/Repair',
                              'Slow Dawn/Operation',
                              'Others(Specified',
                            ]
                                .map((priority) => DropdownMenuItem<String>(
                                      value: priority,
                                      child: Text(' $priority'),
                                    ))
                                .toList(),
                            decoration: fieldDecoration(label: 'Priority', icon: Icons.flag_outlined),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Summary',
                            style: TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Reported By: $reportedBy',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Date/Time: $currentDateTime',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                if (factoryController.text.isEmpty ||
                                    sectionController.text.isEmpty ||
                                    troubleDescriptionController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please fill in all required fields."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                submitTicket();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          isSubmitting ? 'Submitting...' : 'Submit',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
