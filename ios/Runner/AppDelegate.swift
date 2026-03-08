import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String {
      let trimmedApiKey = mapsApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmedApiKey.isEmpty && !trimmedApiKey.contains("$(") {
        GMSServices.provideAPIKey(trimmedApiKey)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
