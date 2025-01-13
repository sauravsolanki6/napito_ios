import UIKit
import Flutter
import GoogleMaps // Add this import

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Google Maps with the provided API key
    GMSServices.provideAPIKey("AIzaSyD0bCf1pahB_iSu7K1PJTHyAfM4CAzjyfM")
    
    // Register all the plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Return the super class method
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
