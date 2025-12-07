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
    
    let api = KeepFreshAPI()
    
    public init() {
        items = cache.load()
        
        rebuildSeenProductIds()
    }
    
    public static func fetch() async {
        let instance = RecentlyConsumed()

        await instance.fetchItems()
    }
    
    private func rebuildSeenProductIds() {
        seenProductIds = Set(items.map { $0.product.id })
    }
    
    public func fetchItems() async {
        do {
            let serverItems = try await api.getInventoryHistory()
            
            let localItems = items
            let merged = mergeItems(local: localItems, server: serverItems)
            
            items = deduplicateByProductId(merged)
            rebuildSeenProductIds()
            
            Task { await cache.save(items) }
        } catch {
            print("Failed to fetch recently consumed items: \(error)")
        }
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
        guard !isLoadingMore, hasMoreData else { return }
        guard let lastItem = items.last else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let newItems = try await api.getInventoryHistory(cursor: lastItem.updatedAt)
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
