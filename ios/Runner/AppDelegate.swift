import Flutter
import UIKit
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase est déjà initialisé par Flutter dans main.dart
    // Pas besoin d'appeler FirebaseApp.configure() ici
    
    // Configurer les notifications push
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    // Enregistrer pour les notifications distantes
    application.registerForRemoteNotifications()
    
    // Configurer Firebase Messaging
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Gérer l'enregistrement du token APNS
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("✅ Token APNS enregistré dans AppDelegate")
  }
  
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Échec de l'enregistrement des notifications: \(error.localizedDescription)")
  }
}

// Extension pour Firebase Messaging
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("✅ Token FCM reçu dans AppDelegate: \(fcmToken ?? "nil")")
    if let fcmToken = fcmToken {
      // Le token sera géré par Flutter
    }
  }
}
