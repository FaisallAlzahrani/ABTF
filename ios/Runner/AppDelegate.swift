import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var notificationsChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase will be initialized in Flutter (main.dart)
    // Do NOT configure here to prevent crashes
    
    GeneratedPluginRegistrant.register(with: self)

    // Register a method channel to allow Flutter to register for remote notifications
    if let controller = window?.rootViewController as? FlutterViewController {
      notificationsChannel = FlutterMethodChannel(
        name: "com.FaisalZahrani.ABTF/notifications",
        binaryMessenger: controller.binaryMessenger
      )
      notificationsChannel?.setMethodCallHandler { (call, result) in
        if call.method == "registerForRemoteNotifications" {
          application.registerForRemoteNotifications()
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
