import BarcodeUI
import DesignSystem
import Environment
import KitchenUI
import Models
import Network
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
                makeNavigationStack(for: .today, router: router)
            } label: {
                AppTab.today.label
            }

            Tab(value: AppTab.search, role: .search) {
                makeNavigationStack(for: .search, router: router)
            } label: {
                AppTab.search.label
            }

            Tab(value: AppTab.kitchen) {
                makeNavigationStack(for: .kitchen, router: router)
            } label: {
                AppTab.kitchen.label
            }.disabled(inventory.state == .loading || inventory.state == .error)
        }
        .tint(.blue600)
        .tabBarMinimizeBehavior(.onScrollDown)
        .sheet(item: $router.presentedSheet) { presentedSheet in
            switch presentedSheet {
            case .barcodeScan:
                BarcodeView()
            case let .inventoryItem(item, action):
                InventoryItemSheetView(inventoryItem: item, action: action)
                    .presentationDetents(
                        item.product.name.count >= 25
                            ? [.custom(AdaptiveExtraLargeDetent.self)]
                            : [.custom(AdaptiveLargeDetent.self)])
                    .presentationDragIndicator(.visible)

            case let .moveInventoryItemDirect(item, storageLocation):
                MoveInventoryItemSheet(
                    inventoryItem: item,
                    storageLocation: storageLocation,
                    recommendedExpiryDate: nil,
                    onMove: { location, expiryDate in
                        if let location {
                            inventory.updateItemStorageLocation(id: item.id, storageLocation: location)
                            inventory.updateItemExpiryDate(id: item.id, expiryDate: expiryDate)
                        }
                        Task {
                            let api = KeepFreshAPI()
                            try? await api.updateInventoryItem(
                                for: item.id,
                                UpdateInventoryItemRequest(
                                    status: nil,
                                    storageLocation: location,
                                    percentageRemaining: nil,
                                    expiryDate: expiryDate
                                )
                            )
                        }
                        router.presentedSheet = nil
                    }
                )
                .presentationDetents([.custom(AdaptiveMediumDetent.self)])
                .presentationDragIndicator(.visible)

            case let .openInventoryItemDirect(item, expiryDate):
                OpenInventoryItemSheet(
                    inventoryItem: item,
                    expiryDate: expiryDate,
                    onOpen: { newExpiryDate in
                        inventory.updateItemStatus(id: item.id, status: .opened)
                        if let newExpiryDate {
                            inventory.updateItemExpiryDate(id: item.id, expiryDate: newExpiryDate)
                        }
                        Task {
                            let api = KeepFreshAPI()
                            try? await api.updateInventoryItem(
                                for: item.id,
                                UpdateInventoryItemRequest(
                                    status: .opened,
                                    storageLocation: nil,
                                    percentageRemaining: nil,
                                    expiryDate: newExpiryDate
                                )
                            )
                        }
                        router.presentedSheet = nil
                    }
                )
                .presentationDetents([.custom(AdaptiveExtraSmallDetent.self)])
                .presentationDragIndicator(.visible)

            case let .removeInventoryItemDirect(item):
                RemoveInventoryItemSheet(
                    inventoryItem: item,
                    onMarkAsDone: { wastePercentage in
                        let status: InventoryItemStatus = wastePercentage == 0 ? .consumed : .discarded
                        inventory.updateItemStatus(id: item.id, status: status)
                        Task {
                            let api = KeepFreshAPI()
                            try? await api.updateInventoryItem(
                                for: item.id,
                                UpdateInventoryItemRequest(
                                    status: status,
                                    storageLocation: nil,
                                    percentageRemaining: wastePercentage,
                                    expiryDate: nil
                                )
                            )
                        }
                        router.presentedSheet = nil
                    }
                )
                .presentationDetents([.custom(AdaptiveSmallDetent.self)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private func makeNavigationStack(for tab: AppTab, router: Router) -> some View {
        @Bindable var router = router

        NavigationStack(path: $router[tab]) {
            tab.rootView()
                .withAppRouter()
                .environment(inventory)
                .environment(\.currentTab, tab)
                .toolbarRole(.browser)
                .toolbar {
                    tab.toolbarContent(router: router)
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
                    router.presentedSheet = .barcodeScan
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain).tint(.white200)
            }
        }
    }
}
