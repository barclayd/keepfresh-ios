import DesignSystem
import Extensions
import Models
import Network
import Notifications
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

    public var state: FetchState = .loading

    let api = KeepFreshAPI()
    private let cache = InventoryCache.shared

    public private(set) var itemsByStorageLocation: [StorageLocation: [InventoryItem]] = [:]
    public private(set) var productCounts: [Int: Int] = [:]
    public private(set) var productsByLocation: [Int: [StorageLocation: [InventoryItem]]] = [:]
    public private(set) var detailsByStorageLocation: [StorageLocation: InventoryLocationDetails] = [:]

    public init(initialState: [InventoryItem] = []) {
        items = cache.load()
        if items.isEmpty {
            items = initialState
        } else {
            state = .loaded
        }
        updateCaches()
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

        Task { await cache.save(items) }
    }

    private func mergeItems(local: [InventoryItem], server: [InventoryItem]) -> [InventoryItem] {
        var serverById = Dictionary(uniqueKeysWithValues: server.map { ($0.id, $0) })
        var result: [InventoryItem] = []

        for localItem in local {
            if let serverItem = serverById[localItem.id] {
                result.append(serverItem.updatedAt > localItem.updatedAt ? serverItem : localItem)
                serverById.removeValue(forKey: localItem.id)
            } else {
                result.append(localItem)
            }
        }

        result.append(contentsOf: serverById.values)

        return result
    }

    public var itemsSortedByRecentlyAddedDescending: [InventoryItem] {
        items.sorted { $0.createdAt > $1.createdAt }
    }

    public var itemsSortedByExpiryAscending: [InventoryItem] {
        items.sorted { $0.expiryDate < $1.expiryDate }
    }

    public func fetchItems() async {
        if items.isEmpty {
            state = .loading
        }

        do {
            let serverItems = try await api.getInventoryItems()
            let localItems = items
            items = mergeItems(local: localItems, server: serverItems)
            state = .loaded
        } catch {
            if items.isEmpty {
                state = .error
            }
            print("Failed to fetch inventory items: \(error)")
        }
    }

    public func addItem(
        request: AddInventoryItemRequest,
        product: ProductSearchResultItemResponse,
        category: ProductSearchItemCategory,
        categorySuggestions: InventorySuggestionsResponse?,
        inventoryItemId: Int,
        icon: String)
    {
        let newItems = Array(
            repeating: InventoryItem(from: request, productSearchResult: product, category: category, id: inventoryItemId, icon: icon),
            count: request.quantity)

        items.append(contentsOf: newItems)

        Task {
            do {
                let response = try await api.addInventoryItem(request)

                if let inventoryItemId = response.inventoryItemId {
                    guard !items.isEmpty else { return }
                    items[items.count - 1].id = inventoryItemId
                }

                if let inventoryItemIds = response.inventoryItemIds {
                    for quantity in 1...inventoryItemIds.count {
                        items[items.count - quantity].id = inventoryItemIds[quantity - 1]
                    }
                }

                if let categorySuggestions {
                    await SuggestionsCache.shared.saveSuggestions(categoryId: category.id, categorySuggestions: categorySuggestions)
                }

                await PushNotifications.shared.requestPushNotifications()
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

    public func deleteItem(id: Int) {
        Task {
            do {
                try await api.deleteInventoryItem(for: id)

                guard let index = items.firstIndex(where: { $0.id == id }) else { return }

                items.remove(at: index)
            } catch {
                print("error deleting item: \(error)")
                return
            }
        }
    }

    public func updateItemStorageLocation(id: Int, storageLocation: StorageLocation) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].storageLocation = storageLocation
        items[index].updatedAt = Date()
    }

    public func updateItemExpiryDate(id: Int, expiryDate: Date) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].expiryDate = expiryDate
        items[index].updatedAt = Date()
    }
}
