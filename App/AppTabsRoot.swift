import BarcodeUI
import DesignSystem
import Environment
import KitchenUI
import Models
import Router
import SearchUI
import SwiftUI
import TodayUI

struct AppTabRootView: View {
    @Environment(Router.self) var router
    @Environment(Inventory.self) var inventory

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(value: AppTab.today) {
                NavigationStack(path: $router[.today]) {
                    TodayView()
                        .withAppRouter()
                        .environment(inventory)
                        .environment(\.currentTab, .today)
                        .toolbarRole(.browser)
                        .toolbar {
                            AppTab.today.toolbarContent(router: router)
                        }
                        .toolbar(router.tabBarVisibilityForCurrentTab, for: .tabBar)
                        .toolbarBackground(AppTab.today.toolbarBackground, for: .navigationBar)
                        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tint(router.customTintColor ?? router.defaultTintColor)
            } label: {
                AppTab.today.label
            }

            Tab(value: AppTab.search, role: .search) {
                NavigationStack(path: $router[.search]) {
                    SearchView()
                        .withAppRouter()
                        .environment(inventory)
                        .environment(\.currentTab, .search)
                        .toolbarRole(.browser)
                        .toolbar {
                            AppTab.search.toolbarContent(router: router)
                        }
                        .toolbar(router.tabBarVisibilityForCurrentTab, for: .tabBar)
                        .toolbarBackground(AppTab.search.toolbarBackground, for: .navigationBar)
                        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tint(router.customTintColor ?? router.defaultTintColor)
            } label: {
                AppTab.search.label
            }

            Tab(value: AppTab.kitchen) {
                NavigationStack(path: $router[.kitchen]) {
                    KitchenView()
                        .withAppRouter()
                        .environment(inventory)
                        .environment(\.currentTab, .kitchen)
                        .toolbarRole(.browser)
                        .toolbar {
                            AppTab.kitchen.toolbarContent(router: router)
                        }
                        .toolbar(router.tabBarVisibilityForCurrentTab, for: .tabBar)
                        .toolbarBackground(AppTab.kitchen.toolbarBackground, for: .navigationBar)
                        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tint(router.customTintColor ?? router.defaultTintColor)
            } label: {
                AppTab.kitchen.label
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .sheet(
            item: $router.presentedSheet,
            content: { presentedSheet in
                switch presentedSheet {
                case .barcodeScan:
                    BarcodeView()
                }
            })
    }
}

@MainActor
private extension AppTab {
    @ViewBuilder
    func rootView(searchText: Binding<String>) -> some View {
        switch self {
        case .today:
            TodayView()
        case .search:
            SearchView()
        case .kitchen:
            KitchenView()
        }
    }
}

public extension AppTab {
    @ViewBuilder
    var label: some View {
        Label(title, systemImage: icon)
            .environment(\.symbolVariants, symbolVariants)
    }

    @MainActor
    @ToolbarContentBuilder
    func toolbarContent(router: Router) -> some ToolbarContent {
        switch self {
        case .today, .kitchen:
            ToolbarItem(placement: .title) {
                Text("KeepFresh")
                    .foregroundColor(.green500).font(Font.custom("Shrikhand-Regular", size: 32, relativeTo: .title))
            }

            ToolbarItemGroup {
                Button(action: {
                    router.selectedTab = .search
                }) {
                    Image(systemName: "plus.app").resizable()
                        .frame(width: 24, height: 24).foregroundColor(.blue600).fontWeight(.bold)
                }
                Button(action: {
                    router.presentedSheet = .barcodeScan
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24).foregroundColor(.blue600).fontWeight(.bold)
                }
            }

        case .search:
            ToolbarItem(placement: .title) {
                Text("Search")
                    .foregroundColor(.white200).font(Font.custom("Shrikhand-Regular", size: 28, relativeTo: .title))
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Barcode scan")
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain).tint(.white200)
            }
        }
    }
}
