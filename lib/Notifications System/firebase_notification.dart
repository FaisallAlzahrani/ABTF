import 'dart:async';
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

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
        print('🔄 FCM token refreshed: $token');
      }, onError: (e) {
        print('❌ FCM token refresh error: $e');
      });

      // Request notification permissions explicitly on iOS
      requestNotificationPermissions();
    } catch (e) {
      print('Error setting up Firebase messaging: $e');
    }
  }

  static NotificationSettings _defaultNotificationSettings() {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.notDetermined,
      alert: AppleNotificationSetting.notSupported,
      announcement: AppleNotificationSetting.notSupported,
      badge: AppleNotificationSetting.notSupported,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.notSupported,
      notificationCenter: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
      showPreviews: AppleShowPreviewSetting.notSupported,
      sound: AppleNotificationSetting.notSupported,
      timeSensitive: AppleNotificationSetting.notSupported,
    );
  }

  static Future<NotificationSettings> requestNotificationPermissions() async {
    try {
      if (!isFirebaseInitialized) {
        print('Firebase not initialized, skipping permission request');
        return _defaultNotificationSettings();
      }

      print('📱 Requesting notification permissions...');
      NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('ℹ️ User granted provisional notification permissions');
      } else {
        print('❌ User declined notification permissions: ${settings.authorizationStatus}');
      }
      return settings;
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return _defaultNotificationSettings();
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
        print('ℹ️ APNS Token not yet available');
      }
      return token;
    } catch (e) {
      print('❌ Error getting APNS token: $e');
      return null;
    }
  }

  static Future<String?> waitForAPNSToken({
    Duration timeout = const Duration(seconds: 15),
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    if (!isFirebaseInitialized) {
      print('Firebase not initialized, cannot wait for APNS token');
      return null;
    }

    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      final token = await getAPNSToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
      await Future.delayed(interval);
    }
    print('❌ APNS token not available after ${timeout.inSeconds}s');
    return null;
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
    // First, request notification permission (required on iOS)
    final settings = await requestNotificationPermissions();

    // Wait a moment for APNs to register after permission
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final fcm = await getFCMToken();
    final apns = await waitForAPNSToken(timeout: const Duration(seconds: 10));

    return {
      'fcm': fcm,
      'apns': apns,
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
