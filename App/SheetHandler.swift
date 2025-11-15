import BarcodeUI
import DesignSystem
import Environment
import Models
import Network
import Router
import SearchUI
import ShoppingUI
import SwiftUI
import TodayUI

extension View {
    func handleAppSheets(router: Router, inventory: Inventory) -> some View {
        sheet(item: Binding(
            get: { router.presentedSheet },
            set: { router.presentedSheet = $0 }))
        { presentedSheet in
            switch presentedSheet {
            case .barcodeScan:
                BarcodeView()

            case .shopppingSearch:
                AddShoppingListItemSheet()
                    .presentationDragIndicator(.visible)

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
                                    expiryDate: expiryDate))
                        }
                        router.presentedSheet = nil
                    })
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
                                    expiryDate: newExpiryDate))
                        }
                        router.presentedSheet = nil
                    })
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
                                    expiryDate: nil))
                        }
                        router.presentedSheet = nil
                    })
                    .presentationDetents([.custom(AdaptiveSmallDetent.self)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
