import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let healthKitManager = HealthKitManager()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      healthKitManager.initializeTypes()
      GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
    } else {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
      
    // Configure the platform channel
    if let controller = window?.rootViewController as? FlutterViewController {
        let healthKitChannel = FlutterMethodChannel(name: "healthKitPermission", binaryMessenger: controller.binaryMessenger)
        healthKitChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "checkPermission") {
                let arguments = call.arguments as? NSDictionary
                let dataTypeName = arguments?["dataTypeName"] as? String
                
                var dict: [String: String] = [:]
                dict[dataTypeName!] = self.healthKitManager.checkHealthKitPermission(name: dataTypeName!)
                result(dict)
            }
            return
        })
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
