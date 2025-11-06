import Foundation
import UserNotifications
import SwiftUI

@MainActor
@Observable
public class PushNotifications: NSObject {
    public static let shared = PushNotifications()
    
    public var pushToken: Data?
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
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
        guard let url = URL(string: "https://your-worker.workers.dev/register-device") else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "deviceToken": token,
            "userId": "user-id-here" // TODO: Get from your auth system
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Token registered: \(httpResponse.statusCode)")
            }
        } catch {
            print("❌ Failed to register token: \(error)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotifications: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        print("📬 Notification tapped: \(userInfo)")
        
        // TODO: Handle deep linking to specific food item
        if let foodId = userInfo["foodId"] as? String {
            await MainActor.run {
                print("Navigate to food: \(foodId)")
                // You'll implement navigation here later
            }
        }
    }
    
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound]
    }
}
