import DesignSystem
import SwiftUI

@Observable
@MainActor
public final class Router {
    private var paths: [AppTab: [RouterDestination]] = [:]
    public subscript(tab: AppTab) -> [RouterDestination] {
        get { paths[tab] ?? [] }
        set { paths[tab] = newValue }
    }

    public var selectedTab: AppTab = .today

    public var presentedSheet: SheetDestination?

    public init() {}

    public var selectedTabPath: [RouterDestination] {
        paths[selectedTab] ?? []
    }

    public var currentTabPathTint: Color? {
        selectedTabPath.last?.tint
    }
    
    public var defaultTintColor: Color = Color.white200
    
    public var customTintColor: Color? = nil

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
