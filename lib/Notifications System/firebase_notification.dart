import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_notifaction.dart';
import 'package:flutter/foundation.dart'; // 👈 Add this

class FirebaseMessagingService {
  @pragma('vm:entry-point') // 👈 keep it available for native calls
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.messageId}');
  }

  static void setupFirebaseMessaging() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Foreground message received: ${message.messageId}');
      if (message.notification != null) {
        print('Notification Title: ${message.notification?.title}');
        print('Notification Body: ${message.notification?.body}');

        // Display the notification
        await LocalNotificationsService.showNotification(
          message.notification.hashCode,
          message.notification?.title,
          message.notification?.body,
        );
      }
    });

    requestNotificationPermissions();
  }

  static Future<void> requestNotificationPermissions() async {
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User declined notification permissions');
    }
  }

  static Future<String?> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('FCM Token: $token');
    }
    return token;
  }

  static Future<void> saveUserDataToFirebase({
    required String email,
    required String departmentId,
    required String name,
    required String fcmToken,
  }) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('Notification_system')
          .doc(email);

      await userRef.set({
        'email': email,
        'department_id': departmentId,
        'name': name,
        'fcm_token': fcmToken,
      }, SetOptions(merge: true));

      print('User data with FCM token saved successfully to Firebase.');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
}
