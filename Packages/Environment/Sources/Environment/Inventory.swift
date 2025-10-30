import DesignSystem
import Extensions
import Models
import Network
import SwiftUI

public struct InventoryLocationDetails: Hashable {
    public var averageConsumptionPredictionPercentage: Int
    public var lastUpdated: Date?
    public var expiringSoonCount: Int
    public var recentlyUpdatedImages: [String]
    public var openItemsCount: Int
    public var itemsCount: Int
    public var recentlyAddedItemsCount: Int
    public var expiringTodayCount: Int

    public var expiryStatusPercentageColor: Color {
        switch averageConsumptionPredictionPercentage {
        case 0...33: .red500
        case 33...66: .yellow400
        default: .green600
        }
    }

    struct InventoryStat: Identifiable {
        var icon: String
        var label: String

        var id: String { icon }
    }
}

@Observable
@MainActor
public final class Inventory {
    public var items: [InventoryItem] = [] {
        didSet {
            updateCaches()
        }
    }

    public var state: FetchState = .empty

    let api = KeepFreshAPI()

    public private(set) var itemsByStorageLocation: [StorageLocation: [InventoryItem]] = [:]
    public private(set) var productCounts: [Int: Int] = [:]
    public private(set) var productsByLocation: [Int: [StorageLocation: [InventoryItem]]] = [:]
    public private(set) var detailsByStorageLocation: [StorageLocation: InventoryLocationDetails] = [:]

    public init(initialState: [InventoryItem] = InventoryItem.mocks(count: 5)) {
        items = initialState
    }

    private func updateCaches() {
        itemsByStorageLocation = Dictionary(grouping: items, by: \.storageLocation)

        detailsByStorageLocation = itemsByStorageLocation.mapValues { items in
            let averageConsumptionPrediction = items
                .isEmpty ? 0 : Int((Double(items.map(\.consumptionPrediction).reduce(0, +)) / Double(items.count)).rounded())

            return InventoryLocationDetails(
                averageConsumptionPredictionPercentage: averageConsumptionPrediction,
                lastUpdated: items.map(\.createdAt).max(),
                expiringSoonCount: items.count(where: { $0.expiryDate.timeUntil.totalDays < 4 }),
                recentlyUpdatedImages: ["popcorn.fill", "birthday.cake.fill", "carrot.fill"],
                openItemsCount: items.count(where: { $0.openedAt != nil }),
                itemsCount: items.count,
                recentlyAddedItemsCount: items
                    .count(where: { $0.createdAt.timeSince.totalDays < 4 }),
                expiringTodayCount: items.count(where: { $0.expiryDate.timeUntil.totalDays == 0 }))
        }

        var counts: [Int: Int] = [:]
        var locationCounts: [Int: [StorageLocation: [InventoryItem]]] = [:]

        for item in items {
            counts[item.product.id, default: 0] += 1

            if locationCounts[item.product.id] == nil {
                locationCounts[item.product.id] = [:]
            }
            if locationCounts[item.product.id]![item.storageLocation] == nil {
                locationCounts[item.product.id]![item.storageLocation] = []
            }
            locationCounts[item.product.id]![item.storageLocation]!.append(item)
        }

        productCounts = counts
        productsByLocation = locationCounts
    }

    public var itemsSortedByRecentlyAddedDescending: [InventoryItem] {
        items.sorted { $0.createdAt > $1.createdAt }
    }

    public var itemsSortedByExpiryAscending: [InventoryItem] {
        items.sorted { $0.expiryDate < $1.expiryDate }
    }

    public func fetchItems() async {
        state = .loading

        do {
            items = try await api.getInventoryItems()
            state = .loaded
        } catch {
            print("loading error")
            state = .error
        }
    }

    public func addItem(
        request: AddInventoryItemRequest,
        category: ProductSearchItemCategory,
        categorySuggestions: InventorySuggestionsResponse?,
        inventoryItemId: Int,
        icon: String)
    {
        let newItems = Array(
            repeating: InventoryItem(from: request, category: category, id: inventoryItemId, icon: icon),
            count: request.quantity)

        items.append(contentsOf: newItems)

        Task.detached { [weak self] in
            do {
                let response = try await self?.api.addInventoryItem(request)

                if let inventoryItemId = response?.inventoryItemId {
                    await MainActor.run { [weak self] in
                        guard let self, !self.items.isEmpty else { return }
                        items[items.count - 1].id = inventoryItemId
                    }
                }

                if let inventoryItemIds = response?.inventoryItemIds {
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        for quantity in 1...inventoryItemIds.count {
                            items[items.count - quantity].id = inventoryItemIds[quantity - 1]
                        }
                    }
                }

                if let categorySuggestions {
                    await SuggestionsCache.shared.saveSuggestions(categoryId: category.id, categorySuggestions: categorySuggestions)
                }
            } catch {
                print("Adding inventory item failed with error: \(error)")

                if let urlError = error as? URLError {
                    print("URL Error details: \(urlError.localizedDescription)")
                }

                if let httpError = error as? DecodingError {
                    print("Decoding error: \(httpError)")
                }

                print("Full error details: \(String(describing: error))")
            }
        }
    }

    public func updateItemStatus(id: Int, status: InventoryItemStatus) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        switch status {
        case .consumed, .discarded:
            items.remove(at: index)
        case .opened:
            items[index].status = status
            items[index].openedAt = Date()
        case .unopened:
            items[index].status = status
            items[index].openedAt = nil
        }
    }

    public func updateItemStorageLocation(id: Int, storageLocation: StorageLocation) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].storageLocation = storageLocation
        items[index].updatedAt = Date()
    }
}
