import BarcodeUI
import DesignSystem
import Environment
import KitchenUI
import Models
import Router
import SearchUI
import ShoppingUI
import SwiftUI
import TodayUI
import Utils

struct AppTabRootView: View {
    @Environment(Router.self) var router
    @Environment(Inventory.self) var inventory
    @Environment(Shopping.self) var shopping

    @Namespace private var inventoryItemAnimation
    @Namespace private var storageLocationAnimation

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(value: AppTab.today) {
                makeNavigationStack(for: .today, router: router, shopping: shopping)
            } label: {
                AppTab.today.label
            }

            Tab(value: AppTab.search, role: .search) {
                makeNavigationStack(for: .search, router: router, shopping: shopping)
            } label: {
                AppTab.search.label
            }

            Tab(value: AppTab.kitchen) {
                makeNavigationStack(for: .kitchen, router: router, shopping: shopping)
            } label: {
                AppTab.kitchen.label
            }

            Tab(value: AppTab.shopping) {
                makeNavigationStack(for: .shopping, router: router, shopping: shopping)
            } label: {
                AppTab.shopping.label
            }
        }
        .tint(.blue600)
        .tabBarMinimizeBehavior(.onScrollDown)
        .handleSheets(router: router, inventory: inventory, shopping: shopping)
        .environment(\.inventoryItemNamespace, inventoryItemAnimation)
        .environment(\.storageLocationNamespace, storageLocationAnimation)
        .conditional { view in
            if #available(iOS 26.1, *) {
                view.tabViewBottomAccessory(isEnabled: router.selectedTab == .shopping) {
                    ShoppingModeBar()
                }
            }
        }
    }

    @ViewBuilder
    private func makeNavigationStack(for tab: AppTab, router: Router, shopping: Shopping) -> some View {
        @Bindable var router = router
        @Bindable var shopping = shopping

        NavigationStack(path: $router[tab]) {
            tab.rootView()
                .withAppRouter()
                .environment(inventory)
                .environment(\.currentTab, tab)
                .toolbarRole(.browser)
                .toolbar {
                    tab.toolbarContent(router: router, shopping: shopping)
                }
                .toolbar(router.tabBarVisibilityForCurrentTab, for: .tabBar)
                .toolbarBackground(tab.toolbarBackground, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
        }
        .tint(router.customTintColor ?? router.defaultTintColor)
    }
}

@MainActor
private extension AppTab {
    @ViewBuilder
    func rootView() -> some View {
        switch self {
        case .today:
            TodayView()
        case .search:
            SearchView()
        case .kitchen:
            KitchenView()
        case .shopping:
            ShoppingView()
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
    func toolbarContent(router: Router, shopping: Shopping) -> some ToolbarContent {
        switch self {
        case .today:
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

        case .kitchen:
            ToolbarItem(placement: .title) {
                Text("Kitchen")
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
                    router.presentedSheet = .barcodeScan
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain).tint(.white200)
            }

        case .shopping:
            ToolbarItem(placement: .title) {
                Text(shopping.shoppingMode == .initial ? "List" : "Shop")
                    .foregroundColor(.green500).font(Font.custom("Shrikhand-Regular", size: 28, relativeTo: .title))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 2.0), value: shopping.shoppingMode)
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    router.selectedTab = .search
                }) {
                    Image(systemName: "plus.app").resizable()
                        .frame(width: 24, height: 24).foregroundColor(.blue600).fontWeight(.bold)
                }
                
                Button(action: {
                    router.presentedSheet = .barcodeScanToShoppingList
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24).foregroundColor(.blue600).fontWeight(.bold)
                }

                if shopping.shoppingMode == .active {
                    Button(action: {
                        router.presentedSheet = .basketDetail(.basket)
                    }) {
                        Image(systemName: "basket.fill").resizable()
                            .frame(width: 24, height: 24).foregroundColor(.blue600).fontWeight(.bold)
                    }
                }
            }
        }
    }
}
