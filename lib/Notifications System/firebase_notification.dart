import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'local_notifaction.dart';
import 'package:flutter/foundation.dart'; // 👈 Add this

class FirebaseMessagingService {
  @pragma('vm:entry-point') // 👈 keep it available for native calls
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.messageId}');
  }

  static bool get isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static void setupFirebaseMessaging() {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, skipping messaging setup');
        return;
      }

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
    } catch (e) {
      print('Error setting up Firebase messaging: $e');
    }
  }

  static Future<void> requestNotificationPermissions() async {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, skipping permission request');
        return;
      }

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
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, cannot get FCM token');
        return null;
      }

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> saveUserDataToFirebase({
    required String email,
    required String departmentId,
    required String name,
    required String fcmToken,
  }) async {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, cannot save user data to Firestore');
        return;
      }

      print('Saving user data to Firestore...');
      print('Email: $email');
      print('Department: $departmentId');
      print('Name: $name');
      print('FCM Token: $fcmToken');

      final userRef = FirebaseFirestore.instance
          .collection('Notification_system')
          .doc(email);

      await userRef.set({
        'email': email,
        'department_id': departmentId,
        'name': name,
        'fcm_token': fcmToken,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      print('✅ User data with FCM token saved successfully to Firebase.');
    } catch (e) {
      print('❌ Error saving user data to Firebase: $e');
    }
  }
}
