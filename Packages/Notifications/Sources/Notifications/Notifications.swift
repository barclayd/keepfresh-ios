import Foundation
import Models
import Network
import SwiftUI
import UserNotifications

extension UNNotification: @retroactive @unchecked Sendable {}
extension UNNotificationResponse: @retroactive @unchecked Sendable {}
extension UNUserNotificationCenter: @retroactive @unchecked Sendable {}

@MainActor
@Observable
public class PushNotifications: NSObject {
    public static var shared = PushNotifications()

    public var pushToken: Data?
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined

    public var handledInventoryItemId: Int?

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
            }
        } catch {}
    }

    public func updateSubscription() async {
        guard let pushToken else {
            return
        }

        let tokenString = pushToken.map { String(format: "%02.2hhx", $0) }.joined()

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
        let environment = await AppEnvironment.detect()
        try? await notificationsAPI.registerDevice(
            RegisterDeviceRequest(
                deviceToken: token,
                platform: "ios",
                appVersion: appVersion,
                environment: environment))
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotifications: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse) async
    {
        let userInfo = response.notification.request.content.userInfo

        guard let inventoryItemId = userInfo["inventoryItemId"] as? Int else {
            return
        }

        guard let event = userInfo["type"] as? String, event == "expiringFood" else {
            return
        }

        handledInventoryItemId = inventoryItemId
    }

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification) async -> UNNotificationPresentationOptions
    {
        [.banner, .sound]
    }
}
