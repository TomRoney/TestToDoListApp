//
//  TestToDoListApp.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UserNotifications

@main
struct TestToDoListApp: App {
    @StateObject private var homeViewModel = HomeViewViewModel() // Ensure HomeViewViewModel is initialized

    // AppDelegate integration to handle notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // Check if the user is signed in
            if homeViewModel.isSignedIn, !homeViewModel.currentUserId.isEmpty {
                HomeView(userId: homeViewModel.currentUserId) // Pass the userId to HomeView
            } else {
                LogInView() // Your login view
            }
        }
    }
}

// Define the AppDelegate class with notification handling
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Enable detailed Auto Layout debugging
        UserDefaults.standard.set(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // Request notification authorization and register for remote notifications
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error during notification authorization: \(error.localizedDescription)")
                return
            }
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("User denied notification permissions.")
            }
        }
        
        // Set Firebase Messaging delegate to self
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Called when APNs successfully registers your app for notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let tokenString = tokenParts.joined()
        print("APNs Device Token: \(tokenString)")
        
        // Now that the APNs token is set, attempt to fetch the FCM token.
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("Fetched FCM registration token after APNs: \(token)")
            }
        }
    }

    // Called when registration for remote notifications fails
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods

    // This method will be called when the app receives a notification in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                   @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification banner, sound, and badge even if the app is open
        completionHandler([.banner, .sound, .badge])
    }
    
    // This method will be called when the user interacts with the notification (for example, tapping it)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response here if needed
        completionHandler()
    }
    
    // MARK: - MessagingDelegate Methods

    // Called when a new FCM token is generated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase Cloud Messaging token: \(fcmToken ?? "")")
        // If necessary, send token to your app server for targeted notifications.
    }
}
