import Foundation
import Models
import Network
import Router
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

    static let inventoryItemExpiring = "INVENTORY_ITEM_EXPIRING"

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
            options: [.foreground],
            icon: icon)
    }

    public static func createCategory(
        status: InventoryItemStatus,
        hasOpenedExpiryDate: Bool,
        suggestions: [String]) -> UNNotificationCategory
    {
        var actions: [UNNotificationAction] = []

        let markOpenAction = UNNotificationAction(
            identifier: NotificationActions.markOpen,
            title: "Mark as Open",
            options: hasOpenedExpiryDate ? [.foreground] : [],
            icon: UNNotificationActionIcon(templateImageName: "tin.open"))

        let markDoneAction = UNNotificationAction(
            identifier: NotificationActions.markDone,
            title: "Mark as Done",
            options: [.destructive, .foreground],
            icon: UNNotificationActionIcon(systemImageName: "trash.fill"))

        if status == .unopened {
            actions.append(markOpenAction)
        }

        actions.append(markDoneAction)

        for suggestion in suggestions.prefix(2) {
            let moveAction = createMoveAction(for: suggestion)
            actions.append(moveAction)
        }

        let categorySuffix = "\(status.rawValue)_\(suggestions.joined(separator: "_"))"
        let categoryId = "\(NotificationActions.categoryPrefix)\(categorySuffix)"

        return UNNotificationCategory(
            identifier: categoryId,
            actions: actions,
            intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nil, categorySummaryFormat: "%u items expiring")
    }
}

@MainActor
@Observable
public class PushNotifications: NSObject {
    public static var shared = PushNotifications()

    public var pushToken: Data?
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined

    public var pendingNotification: PendingNotification?
    public var shouldRefreshInventory: Bool = false

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
                environment: environment))
    }

    private func parseDateFromPayload(_ value: Any?) -> Date? {
        guard let dateString = value as? String else { return nil }
        return ISO8601DateFormatter().date(from: dateString)
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

        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {
        case NotificationActions.markOpen:
            if let expiryDate = parseDateFromPayload(userInfo["openedExpiryDate"]) {
                pendingNotification = PendingNotification(
                    inventoryItemId: inventoryItemId,
                    action: .open(expiryDate))
            } else {
                // Runs in background
                Task {
                    let api = KeepFreshAPI()
                    do {
                        try await api.updateInventoryItem(
                            for: inventoryItemId,
                            UpdateInventoryItemRequest(
                                status: .opened,
                                storageLocation: nil,
                                percentageRemaining: nil,
                                expiryDate: nil))

                        await MainActor.run {
                            self.shouldRefreshInventory = true
                        }
                    } catch {
                        // Silent failure
                    }
                }
            }

        case NotificationActions.markDone:
            pendingNotification = PendingNotification(
                inventoryItemId: inventoryItemId,
                action: .remove)

        case NotificationActions.moveToPantry:
            pendingNotification = PendingNotification(
                inventoryItemId: inventoryItemId,
                action: .move(.pantry))

        case NotificationActions.moveToFridge:
            pendingNotification = PendingNotification(
                inventoryItemId: inventoryItemId,
                action: .move(.fridge))

        case NotificationActions.moveToFreezer:
            pendingNotification = PendingNotification(
                inventoryItemId: inventoryItemId,
                action: .move(.freezer))

        default:
            pendingNotification = PendingNotification(
                inventoryItemId: inventoryItemId,
                action: nil)
        }
    }

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification) async -> UNNotificationPresentationOptions
    {
        [.banner, .sound]
    }
}
