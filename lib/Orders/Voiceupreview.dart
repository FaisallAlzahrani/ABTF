import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VoiceUpRequesting extends StatelessWidget {
  final dynamic message; // Accepting the whole message object

  // Constructor to accept the message object
  VoiceUpRequesting({required this.message});

  @override
  Widget build(BuildContext context) {
    final text = message['message'] ?? 'No content available';
    final timestamp = message['timestamp']?.toDate().toString() ?? 'No timestamp available';
    final stageone = message['Stageone'];
    final stagetwo = message['Stagetwo'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Up Requesting'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Content
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Timestamp
            Text(
              'Timestamp: $timestamp',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            // Status
            Text(
              'Current Status: $stagetwo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 20),
            // Buttons: Approve and Reject
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Update 'stagetwo' to 'Approved'
                    FirebaseFirestore.instance
                        .collection('voice_up_messages')
                        .doc(message.id)
                        .update({'Stageone': '13012', 'Statusofmassage': 'Approved'}).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message Approved')),
                      );
                      Navigator.pop(context); // Go back after approval
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update 'stagetwo' to 'Rejected'
                    FirebaseFirestore.instance
                        .collection('voice_up_messages')
                        .doc(message.id)
                        .update({'Statusofmassage': 'Reject'}).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message Rejected')),
                      );
                      Navigator.pop(context); // Go back after rejection
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
