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

    public init() {}

    public func loadInitial() async {
        let api = KeepFreshAPI()
        do {
            let newItems = try await api.getInventoryHistory()
            seenProductIds.removeAll()
            items.removeAll()
            for item in newItems {
                if seenProductIds.insert(item.product.id).inserted {
                    items.append(item)
                }
            }
        } catch {
            items = []
        }
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

        let api = KeepFreshAPI()
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
            }
        } catch {}
    }
}
