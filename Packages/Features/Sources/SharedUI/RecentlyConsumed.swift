import Models
import Network
import SwiftUI

@MainActor
@Observable
public final class RecentlyConsumed {
    public private(set) var items: [InventoryItem] = []
    public private(set) var isLoadingMore = false
    public private(set) var hasMoreData = true

    private var seenProductIds: Set<Int> = []
    private let cache = RecentlyConsumedCache.shared
    private var refreshGeneration = 0

    let api = KeepFreshAPI()

    public init() {
        items = cache.load()

        rebuildSeenProductIds()
    }

    public func addItem(_ item: InventoryItem) {
        var newItem = item
        newItem.updatedAt = Date()

        items.removeAll { $0.product.id == newItem.product.id }
        items.insert(newItem, at: 0)
        rebuildSeenProductIds()

        Task { await cache.save(items) }
    }

    private func rebuildSeenProductIds() {
        seenProductIds = Set(items.map(\.product.id))
    }

    public func fetchItems() async {
        await fetchItems { try await self.api.getInventoryHistory() }
    }

    func fetchItems(fetch: () async throws -> [InventoryItem]) async {
        refreshGeneration += 1
        let generation = refreshGeneration
        let initialItems = items
        isLoadingMore = false
        do {
            let serverItems = try await fetch()
            guard generation == refreshGeneration else { return }
            // This is the first page of the current account's history. Older pages can
            // be fetched again; cached history from a previous account must not survive.
            let addedDuringRefresh = items.filter { !initialItems.contains($0) }
            items = deduplicateByProductId(serverItems + addedDuringRefresh)
            hasMoreData = !serverItems.isEmpty
            rebuildSeenProductIds()

            Task { await cache.save(items) }
        } catch {
            print("Failed to fetch recently consumed items: \(error)")
        }
    }

    private func deduplicateByProductId(_ items: [InventoryItem]) -> [InventoryItem] {
        var latestByProductId: [Int: InventoryItem] = [:]
        for item in items {
            if let existing = latestByProductId[item.product.id] {
                if item.updatedAt > existing.updatedAt {
                    latestByProductId[item.product.id] = item
                }
            } else {
                latestByProductId[item.product.id] = item
            }
        }
        return latestByProductId.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    public func loadMoreIfNeeded(currentItem: InventoryItem) async {
        guard currentItem.id == items.last?.id,
              hasMoreData,
              !isLoadingMore else { return }

        await loadMore()
    }

    private func loadMore() async {
        await loadMore { try await self.api.getInventoryHistory(cursor: $0) }
    }

    func loadMore(fetch: (Date) async throws -> [InventoryItem]) async {
        guard !isLoadingMore, hasMoreData else { return }
        guard let lastItem = items.last else { return }

        isLoadingMore = true
        let generation = refreshGeneration
        defer {
            if generation == refreshGeneration { isLoadingMore = false }
        }

        do {
            let newItems = try await fetch(lastItem.updatedAt)
            guard generation == refreshGeneration else { return }
            if newItems.isEmpty {
                hasMoreData = false
            } else {
                for item in newItems {
                    if seenProductIds.insert(item.product.id).inserted {
                        items.append(item)
                    }
                }
                Task { await cache.save(items) }
            }
        } catch {}
    }
}
