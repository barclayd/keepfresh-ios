import Foundation
import Models
import Network
import SwiftUI
import UserNotifications

extension UNNotification: @retroactive @unchecked Sendable {}
extension UNNotificationResponse: @retroactive @unchecked Sendable {}
extension UNUserNotificationCenter: @retroactive @unchecked Sendable {}

public enum NotificationActions {
    static let markOpen = "MARK_AS_OPEN"
    static let markDone = "MARK_AS_DONE"
    static let moveToPantry = "MOVE_TO_PANTRY"
    static let moveToFridge = "MOVE_TO_FRIDGE"
    static let moveToFreezer = "MOVE_TO_FREEZER"
    
    static let categoryPrefix = "FOOD_EXPIRING_"
    
    private static func createMoveAction(for location: String) -> UNNotificationAction {
        let identifier: String
        let title: String
        let iconName: String
        
        switch location.lowercased() {
        case "pantry":
            identifier = NotificationActions.moveToPantry
            title = "Move to Pantry"
            iconName = StorageLocation.pantry.icon
            
        case "fridge":
            identifier = NotificationActions.moveToFridge
            title = "Move to Fridge"
            iconName = StorageLocation.fridge.icon
            
        case "freezer":
            identifier = NotificationActions.moveToFreezer
            title = "Move to Freezer"
            iconName = StorageLocation.freezer.icon
            
        default:
            identifier = "MOVE_TO_\(location.uppercased())"
            title = "Move to \(location.capitalized)"
            iconName = StorageLocation.pantry.icon
        }
        
        let icon = UNNotificationActionIcon(systemImageName: iconName)
        
        return UNNotificationAction(
            identifier: identifier,
            title: title,
            options: [],
            icon: icon
        )
    }
    
    public static func createCategory(
        suggestions: [String]
    ) -> UNNotificationCategory {
        var actions: [UNNotificationAction] = []
        
        let markOpenAction = UNNotificationAction(
            identifier: NotificationActions.markOpen,
            title: "Mark as Open",
            options: [],
            icon: UNNotificationActionIcon(templateImageName: "tin.open")
        )
        
        let markDoneAction = UNNotificationAction(
            identifier: NotificationActions.markDone,
            title: "Mark as Done",
            options: [],
            icon: UNNotificationActionIcon(systemImageName: "trash.fill")
        )
        
        actions.append(markOpenAction)
        actions.append(markDoneAction)
                
        for suggestion in suggestions.prefix(2) {
            let moveAction = createMoveAction(for: suggestion)
            actions.append(moveAction)
        }
        
        let categorySuffix = suggestions.joined(separator: "_")
        let categoryId = "\(NotificationActions.categoryPrefix)\(categorySuffix)"
        
        return UNNotificationCategory(
            identifier: categoryId,
            actions: actions,
            intentIdentifiers: []
        )
    }
}

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
        let environment = AppEnvironment.detect()
        try? await notificationsAPI.registerDevice(
            RegisterDeviceRequest(
                deviceToken: token,
                platform: "ios",
                appVersion: appVersion,
                environment: environment
            ))
    }
    
    private func handleMarkOpen(inventoryItemId: Int) async {
        print("Mark Open: \(inventoryItemId)")
        
        // Set this so your app can navigate to the item if needed
        handledInventoryItemId = inventoryItemId
    }

    private func handleMarkDone(inventoryItemId: Int) async {
        // TODO: Call your API to mark the item as done/consumed
        print("Mark Done: \(inventoryItemId)")
        
        handledInventoryItemId = inventoryItemId
    }

    private func handleMoveItem(inventoryItemId: Int, to location: String) async {
        // TODO: Call your API to move the item to the new location
        print("Move item \(inventoryItemId) to \(location)")
        
        handledInventoryItemId = inventoryItemId
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotifications: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        
        guard let inventoryItemId = userInfo["inventoryItemId"] as? Int else {
            return
        }
        
        guard let event = userInfo["type"] as? String, event == "expiringFood" else {
            return
        }
        
        let actionIdentifier = response.actionIdentifier
        
        print("actionIdentifier: \(actionIdentifier)")
        
        switch actionIdentifier {
        case NotificationActions.markOpen:
            await handleMarkOpen(inventoryItemId: inventoryItemId)
            
        case NotificationActions.markDone:
            await handleMarkDone(inventoryItemId: inventoryItemId)
            
        case NotificationActions.moveToPantry:
            await handleMoveItem(inventoryItemId: inventoryItemId, to: "pantry")
            
        case NotificationActions.moveToFridge:
            await handleMoveItem(inventoryItemId: inventoryItemId, to: "fridge")
            
        case NotificationActions.moveToFreezer:
            await handleMoveItem(inventoryItemId: inventoryItemId, to: "freezer")
            
        default:
            handledInventoryItemId = inventoryItemId
        }
    }
    
    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
