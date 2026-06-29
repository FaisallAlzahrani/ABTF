import 'dart:convert';
import 'package:application_v1/Announcement/Announcement.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import '../Notifications System/google_auth_services.dart';

class AnnouncementPost extends StatefulWidget {
  @override
  _AnnouncementPostState createState() => _AnnouncementPostState();
}


Future<void> notifyAll({
  required String Notificationtitle,
  required String Notificationtext,
}) async {
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
        }),
      );


      if (response.statusCode != 200) {
        print('Error sending notification to $token: ${response.body}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}


class _AnnouncementPostState extends State<AnnouncementPost> {
  double screenHeight = 0;
  double screenWidth = 0;
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _postAnnouncement() async {
    String message = _controller.text.trim();

    if (message.isNotEmpty) {
      await _firestore.collection('announcements').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await notifyAll(
        Notificationtitle: 'New Announcement',
        Notificationtext: message,


      );

      // Clear the TextField after posting
      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Announcement posted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write something to post!')),
      );
    }print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Announcement",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "What's Up?",
                  style: TextStyle(
                    fontSize: screenHeight*0.026,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),SizedBox(width: screenHeight*0.15,),Icon(Icons.info_outline_rounded),

                SizedBox(
                  width: screenHeight*0.125,
                  child: GestureDetector(
                    onTap : () {

                      // Perform action when container is clicked

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return Announcement();
                        }),);
                      Style(
                        backgroundColor: Colors.blue[900],
                      );

                    },


                    child:
                    Text(
                      " Announcement",
                      style: TextStyle(fontSize: screenHeight*0.016,color: Colors.blue[900]),
                    ),
                  ),

                ),

              ],
            ),



            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                maxLines: 30,
                decoration: InputDecoration(
                  hintText: "Write your announcement here...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(

                  onPressed: _postAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                  ),
                  child: Text(
                    "Post",
                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                ),
              ),
            ],)

          ],
        ),
      ),
    ));
  }
}


