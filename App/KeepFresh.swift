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
    @State var shopping: Shopping = .init(items: KeepFreshApp.mockShoppingItems)
    @State var pushNotifications = PushNotifications.shared

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppTabRootView()
                .environment(router)
                .environment(inventory)
                .environment(shopping)
                .modelContainer(for: [RecentSearch.self, GenmojiCache.self])
                .task {
                    try? await Authentication.shared.signInAnonymously()

                    await inventory.fetchItems()

                    Task.detached {
                        await SuggestionsCache.shared.load()
                    }
                }
                .preferredColorScheme(.light)
                .onChange(of: pushNotifications.shouldRefreshInventory) { _, shouldRefresh in
                    guard shouldRefresh, inventory.state != .loading || inventory.state != .loaded else {
                        pushNotifications.shouldRefreshInventory = false
                        return
                    }

                    pushNotifications.shouldRefreshInventory = false

                    Task {
                        await inventory.fetchItems()
                    }
                }
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

                        if let action = notification.action {
                            switch action {
                            case let .open(date):
                                router.presentedSheet = .openInventoryItemDirect(item, date)
                            case .remove:
                                router.presentedSheet = .removeInventoryItemDirect(item)
                            case let .move(location):
                                router.presentedSheet = .moveInventoryItemDirect(item, location)
                            case .edit:
                                router.presentedSheet = .inventoryItem(item, .edit)
                            }
                        } else {
                            router.presentedSheet = .inventoryItem(item, nil)
                        }
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

                        if let action = notification.action {
                            switch action {
                            case let .open(date):
                                router.presentedSheet = .openInventoryItemDirect(item, date)
                            case .remove:
                                router.presentedSheet = .removeInventoryItemDirect(item)
                            case let .move(location):
                                router.presentedSheet = .moveInventoryItemDirect(item, location)
                            case .edit:
                                router.presentedSheet = .inventoryItem(item, .edit)
                            }
                        } else {
                            router.presentedSheet = .inventoryItem(item, nil)
                        }
                    }
                }
        }
    }

    // Mock data for testing
    static var mockShoppingItems: [ShoppingItem] {
        [
            ShoppingItem(
                id: 1,
                title: nil,
                createdAt: Date(),
                updatedAt: Date(),
                source: .userAdded,
                status: .added,
                storageLocation: .fridge,
                product: Product(
                    id: 1,
                    name: "Semi Skimmed Milk",
                    unit: "pts",
                    brand: .tesco,
                    amount: 4,
                    category: CategoryDetails(
                        icon: "milk",
                        id: 1,
                        name: "Milk",
                        pathDisplay: "Fresh Food > Dairy > Milk"))),
            ShoppingItem(
                id: 2,
                title: nil,
                createdAt: Date(),
                updatedAt: Date(),
                source: .userAdded,
                status: .added,
                storageLocation: .fridge,
                product: Product(
                    id: 2,
                    name: "Whole Milk",
                    unit: "pts",
                    brand: .tesco,
                    amount: 4,
                    category: CategoryDetails(
                        icon: "milk",
                        id: 1,
                        name: "Milk",
                        pathDisplay: "Fresh Food > Dairy > Milk"))),
            ShoppingItem(
                id: 3,
                title: nil,
                createdAt: Date(),
                updatedAt: Date(),
                source: .userAdded,
                status: .added,
                storageLocation: .freezer,
                product: Product(
                    id: 3,
                    name: "Ice Cream",
                    unit: "tubs",
                    brand: .tesco,
                    amount: 2,
                    category: CategoryDetails(
                        icon: "icecream",
                        id: 2,
                        name: "Desserts",
                        pathDisplay: "Frozen > Desserts"))),
        ]
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
