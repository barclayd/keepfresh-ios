import Foundation
import Models
import Network
import SwiftUI
import UserNotifications

@MainActor
@Observable
public class PushNotifications: NSObject {
    public static let shared = PushNotifications()

    public var pushToken: Data?
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self

        Task {
            await updateAuthorizationStatus()
        }
    }

    // MARK: - Public Methods

    public func requestPushNotifications() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            await updateAuthorizationStatus()

            if granted {
                await registerForRemoteNotifications()
            } else {
                print("⚠️ Push notification permission denied")
            }
        } catch {
            print("❌ Error requesting authorization: \(error)")
        }
    }

    public func updateSubscription() async {
        guard let pushToken else {
            print("⚠️ No push token available")
            return
        }

        let tokenString = pushToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Updating subscription with token: \(tokenString)")

        await sendTokenToBackend(token: tokenString)
    }

    // MARK: - Private Methods

    private func updateAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    private func sendTokenToBackend(token: String) async {
        let notificationsAPI = KeepFreshNotificationsAPI()

        let appVersion = Bundle.main.appVersion
        try? await notificationsAPI.registerDevice(
            RegisterDeviceRequest(
                deviceToken: token,
                platform: "ios",
                appVersion: appVersion))
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotifications: UNUserNotificationCenterDelegate {
    public nonisolated func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse) async
    {
        let userInfo = response.notification.request.content.userInfo
        print("📬 Notification tapped: \(userInfo)")

        await MainActor.run {
            // Put your handling code here
            // For example:
            // self.someProperty = something
            // or call a method that updates state
        }
    }

    public nonisolated func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification) async -> UNNotificationPresentationOptions
    {
        // Show notification even when app is in foreground
        [.banner, .sound]
    }
}
