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
    public var confettiTrigger: Int = 0

    let api = KeepFreshAPI()
    private let cache = InventoryCache.shared
    private var refreshGeneration = 0
    private var pendingItemIds: Set<Int> = []

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

    private func mergeItems(local: [InventoryItem], server: [InventoryItem], startingIds: Set<Int>) -> [InventoryItem] {
        let removedIds = startingIds.subtracting(local.map(\.id))
        var serverById = Dictionary(uniqueKeysWithValues: server.filter { !removedIds.contains($0.id) }.map { ($0.id, $0) })
        var result: [InventoryItem] = []

        for localItem in local {
            if let serverItem = serverById[localItem.id] {
                result.append(serverItem.updatedAt > localItem.updatedAt ? serverItem : localItem)
                serverById.removeValue(forKey: localItem.id)
            } else if !startingIds.contains(localItem.id) || pendingItemIds.contains(localItem.id) {
                // Keep additions made during this refresh, but drop stale saved entries.
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
        await fetchItems { try await self.api.getInventoryItems() }
    }

    func fetchItems(fetch: () async throws -> [InventoryItem]) async {
        if items.isEmpty {
            state = .loading
        }

        refreshGeneration += 1
        let generation = refreshGeneration
        let startingIds = Set(items.map(\.id))
        do {
            let serverItems = try await fetch()
            guard generation == refreshGeneration else { return }
            let localItems = items
            items = mergeItems(local: localItems, server: serverItems, startingIds: startingIds)
            state = .loaded
        } catch {
            guard generation == refreshGeneration else { return }
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

        pendingItemIds.insert(inventoryItemId)
        items.append(contentsOf: newItems)

        Task {
            defer { pendingItemIds.remove(inventoryItemId) }
            do {
                let response = try await api.addInventoryItem(request)

                // A refresh may have removed unrelated entries while this add was pending.
                let newIds = response.inventoryItemIds ?? response.inventoryItemId.map { [$0] } ?? []
                let indices = items.indices.filter { items[$0].id == inventoryItemId }
                for (index, id) in zip(indices, newIds) {
                    items[index].id = id
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

    public func triggerConfetti() {
        confettiTrigger += 1
    }
}
