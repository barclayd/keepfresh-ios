import DesignSystem
import InventoryUI
import Router
import SearchUI
import SwiftUI
import TodayUI

struct AppTabRootView: View {
    @Environment(Router.self) var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack(path: $router[tab]) {
                    tab.rootView
                        .withAppRouter()
                        .environment(\.currentTab, tab)
                }
                .tabItem { tab.label }
                .tag(tab)
            }
        }
    }
}

@MainActor
private extension AppTab {
    @ViewBuilder
    var rootView: some View {
        switch self {
        case .search:
            SearchView()
        case .today:
            TodayView()
        case .kitchen:
            InventoryView()
        }
    }
}
