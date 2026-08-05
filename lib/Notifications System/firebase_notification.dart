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
        print('✅ FCM Token: $token');
      }
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  static Future<String?> getAPNSToken() async {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, cannot get APNS token');
        return null;
      }

      String? token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null) {
        print('✅ APNS Token: $token');
      } else {
        print('ℹ️ APNS Token not yet available (will retry later)');
      }
      return token;
    } catch (e) {
      print('❌ Error getting APNS token: $e');
      return null;
    }
  }

  static Future<void> refreshFCMToken() async {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, cannot refresh token');
        return;
      }

      print('Refreshing FCM token...');
      await FirebaseMessaging.instance.deleteToken();
      String? token = await FirebaseMessaging.instance.getToken();
      print('✅ Refreshed FCM Token: $token');
    } catch (e) {
      print('❌ Error refreshing FCM token: $e');
    }
  }

  static Future<Map<String, String?>> getTokens() async {
    return {
      'fcm': await getFCMToken(),
      'apns': await getAPNSToken(),
    };
  }

  static Future<void> saveUserDataToFirebase({
    required String email,
    required String departmentId,
    required String name,
    String? fcmToken,
    String? apnsToken,
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
      print('APNS Token: $apnsToken');

      final userRef = FirebaseFirestore.instance
          .collection('Notification_system')
          .doc(email);

      final data = <String, dynamic>{
        'email': email,
        'department_id': departmentId,
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fcmToken != null) {
        data['fcm_token'] = fcmToken;
      }
      if (apnsToken != null) {
        data['apns_token'] = apnsToken;
      }

      await userRef.set(data, SetOptions(merge: true));

      print('✅ User data with tokens saved successfully to Firebase.');
    } catch (e) {
      print('❌ Error saving user data to Firebase: $e');
    }
  }
}
