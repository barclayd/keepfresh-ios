import Authentication
import DesignSystem
import Environment
import Models
import Notifications
import Router
import SwiftData
import SwiftUI
import UserNotifications

@main
struct KeepFreshApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @State var router: Router = .init()
    @State var inventory: Inventory = .init()
    @State var pushNotifications = PushNotifications.shared

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppTabRootView()
                .environment(router)
                .environment(inventory)
                .modelContainer(for: [RecentSearch.self, GenmojiCache.self])
                .task {
                    try? await Authentication.shared.signInAnonymously()

                    await inventory.fetchItems()

                    Task.detached {
                        await SuggestionsCache.shared.load()
                    }
                }
                .preferredColorScheme(.light)
                .onChange(of: pushNotifications.pendingNotification) { _, notification in
                    guard let notification else { return }

                    pushNotifications.pendingNotification = nil

                    router.pendingNotification = notification
                }
                .onChange(of: inventory.state) { _, newState in
                    guard newState == .loaded,
                          let notification = router.pendingNotification
                    else {
                        return
                    }

                    router.pendingNotification = nil

                    guard let item = inventory.items.first(where: { $0.id == notification.inventoryItemId }) else {
                        return
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        router.selectedTab = .today
                        router.popToRoot(for: .today)
                        router.presentedSheet = .inventoryItem(item, notification.action)
                    }
                }
                .onChange(of: router.pendingNotification) { _, notification in
                    guard let notification,
                          inventory.state == .loaded
                    else {
                        return
                    }

                    router.pendingNotification = nil

                    guard let item = inventory.items.first(where: { $0.id == notification.inventoryItemId }) else {
                        return
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        router.selectedTab = .today
                        router.popToRoot(for: .today)
                        router.presentedSheet = .inventoryItem(item, notification.action)
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        true
    }

    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        Task { @MainActor in
            PushNotifications.shared.pushToken = deviceToken
            await PushNotifications.shared.updateSubscription()
        }
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        print("Notification received")
        print("userInfo: \(userInfo)")
        completionHandler(.newData)
    }

    func application(
        _: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Failed to register: \(error)")
    }
}
