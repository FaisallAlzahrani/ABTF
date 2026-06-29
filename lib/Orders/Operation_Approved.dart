import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Notifications System/google_auth_services.dart';
import '../login/user_provider.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class OperationApprovedPage extends StatelessWidget {
  double screenHeight = 0;
  double screenWidth = 0;
  final QueryDocumentSnapshot ticket;


  OperationApprovedPage({required this.ticket}); // Constructor accepts the ticket


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final ticketData = ticket.data() as Map<String, dynamic>;
    String? Operation_Approved = Provider.of<UserProvider>(context).firstName;
    String currentDateTime4 = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());


    Future<void> notifyofRapair({
      required String Notificationtitle,
      required String Notificationtext,
    }) async {
      const String maintmanagername = "NiteshKumbhar";

      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Notification_system')
          .where('name', isEqualTo: maintmanagername)
          .get();
      try {
        // Fetch all FCM tokens from Firestore
        final QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('Notification_system').get();

        print('Users fetched: ${usersSnapshot.docs.length}');

        // Extract FCM tokens from Firestore
        final List<String> fcmTokens = usersSnapshot.docs
            .map((doc) => doc['fcm_token'] as String?)
            .where((token) => token != null && token.isNotEmpty)
            .cast<String>()
            .toList();


        if (fcmTokens.isEmpty) {
          print('No FCM tokens found.');
          return;
        }
        final GoogleAuthService authService = GoogleAuthService();

        // Your existing OAuth Bearer Token
        final String bearerToken =
        await authService.getOAuth2BearerToken();

        for (String token in fcmTokens) {
          final response = await http.post(
            Uri.parse(
                'https://fcm.googleapis.com/v1/projects/towerapp-fec08/messages:send'),
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


              },
            },
            ),
          );


          if (response.statusCode != 200) {
            print('Error sending notification to $token: ${response.body}');
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    const brandColor = Color(0xFF104164);

    final bool isAlreadyApproved = ticketData['Operation'] == 'Approved';
    final String reqNumber = '${ticketData['Requisition Number'] ?? ''}';

    void approveTicket() {
      FirebaseFirestore.instance.collection('Tickets').doc(ticket.id).update({
        'Operation': 'Approved',
        'status4': Operation_Approved,
        'Data_Time4': currentDateTime4
      });
      notifyofRapair(
        Notificationtitle: 'Receve of Repair complation #${ticketData['Requisition Number']} Ready',
        Notificationtext: 'has been Approve',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket Approved')),
      );
      Navigator.pop(context);
    }

    Widget infoRow({required String label, required String value}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.70),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Ticket Reviewing',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth.clamp(0, 900);
          final double padding = (maxWidth * 0.04).clamp(12.0, 20.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(padding, 12, padding, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[50],
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: brandColor.withOpacity(0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: brandColor.withOpacity(0.12)),
                                  ),
                                  child: const Icon(Icons.fact_check_outlined, color: brandColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Requisition #$reqNumber',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: brandColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isAlreadyApproved
                                            ? 'This ticket has already been received after repair completion.'
                                            : 'Review details and confirm received after repair completion.',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.55),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: brandColor.withOpacity(0.12)),
                                  ),
                                  child: Text(
                                    isAlreadyApproved ? 'Approved' : 'Pending',
                                    style: TextStyle(
                                      color: isAlreadyApproved ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[50],
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: brandColor.withOpacity(0.12)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoRow(label: 'Factory', value: '${ticketData['Factory'] ?? 'N/A'}'),
                                infoRow(label: 'Section', value: '${ticketData['Section'] ?? 'N/A'}'),
                                infoRow(label: 'Machine Equipment', value: '${ticketData['machineEquipment'] ?? 'N/A'}'),
                                infoRow(label: 'Serial No', value: '${ticketData['Serial Number'] ?? 'N/A'}'),
                                infoRow(label: 'Priority', value: '${ticketData['Priority'] ?? 'N/A'}'),
                                infoRow(label: 'Reported By', value: '${ticketData['Reported_By'] ?? 'N/A'}'),
                                infoRow(label: 'Reported Date/Time', value: '${ticketData['Date_Time'] ?? 'N/A'}'),
                                infoRow(label: 'Received By', value: '${ticketData['RecevedBy'] ?? 'N/A'}'),
                                infoRow(label: 'Received Date/Time', value: '${ticketData['Date_Time2'] ?? 'N/A'}'),
                                const SizedBox(height: 6),
                                Text(
                                  'Trouble Description',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.72),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${ticketData['TroubleDescription'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.75),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[50],
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: brandColor.withOpacity(0.12)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Repair Completion Receipt',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.72),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                infoRow(label: 'User', value: Operation_Approved ?? ''),
                                infoRow(label: 'Date/Time', value: currentDateTime4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(padding, 8, padding, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isAlreadyApproved ? null : approveTicket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Received After Repair Completion',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
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
