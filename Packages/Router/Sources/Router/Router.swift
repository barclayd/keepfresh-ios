import DesignSystem
import SwiftUI

public struct PendingNotification: Equatable {
    public let inventoryItemId: Int
    public let action: InventoryItemAction?

    public init(inventoryItemId: Int, action: InventoryItemAction? = nil) {
        self.inventoryItemId = inventoryItemId
        self.action = action
    }
}

@Observable
@MainActor
public final class Router {
    private var paths: [AppTab: [RouterDestination]] = [:]
    public subscript(tab: AppTab) -> [RouterDestination] {
        get { paths[tab] ?? [] }
        set { paths[tab] = newValue }
    }

    // reset
    public var selectedTab: AppTab = .shopping

    public var presentedSheet: SheetDestination?

    public var selectedInventoryItemForDeepLink: Int?

    public var pendingNotification: PendingNotification?

    public init() {}

    public var selectedTabPath: [RouterDestination] {
        paths[selectedTab] ?? []
    }

    public var currentTabPathTint: Color? {
        selectedTabPath.last?.tint
    }

    public var defaultTintColor: Color = .white200

    public var customTintColor: Color?

    public var tabBarVisibilityForCurrentTab: Visibility {
        selectedTabPath.last?.tabBarVisibility ?? .automatic
    }

    public func popToRoot(for tab: AppTab? = nil) {
        paths[tab ?? selectedTab] = []
    }

    public func popNavigation(for tab: AppTab? = nil) {
        paths[tab ?? selectedTab]?.removeLast()
    }

    public func navigateTo(_ destination: RouterDestination, for tab: AppTab? = nil) {
        if paths[tab ?? selectedTab] == nil {
            paths[tab ?? selectedTab] = [destination]
        } else {
            paths[tab ?? selectedTab]?.append(destination)
        }
    }
}
