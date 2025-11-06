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
    @State var notifications: PushNotifications = PushNotifications.shared

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
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            PushNotifications.shared.pushToken = deviceToken
            await PushNotifications.shared.updateSubscription()
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register: \(error)")
    }
}
