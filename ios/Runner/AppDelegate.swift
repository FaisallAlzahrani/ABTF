import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase with proper error handling
    if FirebaseApp.app() == nil {
      do {
        try FirebaseApp.configure()
        print("✅ Firebase configured successfully in AppDelegate")
      } catch {
        print("❌ Firebase configuration failed: \(error)")
        // Continue without Firebase - don't crash
      }
    } else {
      print("✅ Firebase already configured")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
