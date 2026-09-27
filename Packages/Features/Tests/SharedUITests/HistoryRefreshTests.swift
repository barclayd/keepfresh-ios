import Foundation
import Models
@testable import SharedUI
import Testing

@Suite(.serialized)
@MainActor
struct HistoryRefreshTests {
    @Test func emptyRefreshClearsOldAccountHistory() async {
        let history = RecentlyConsumed()
        history.addItem(InventoryItem.mock(id: 10))

        await history.fetchItems { [] }

        #expect(history.items.isEmpty)
        #expect(!history.hasMoreData)
    }

    @Test func failedRefreshKeepsOfflineHistory() async {
        let history = RecentlyConsumed()
        await history.fetchItems { [] }
        history.addItem(InventoryItem.mock(id: 10))
        let cached = history.items

        await history.fetchItems { throw URLError(.notConnectedToInternet) }

        #expect(history.items == cached)
    }

    @Test func refreshPreservesItemsConsumedWhileRequestWasInFlight() async {
        let history = RecentlyConsumed()
        await history.fetchItems { [] }

        await history.fetchItems {
            history.addItem(InventoryItem.mock(id: 10))
            return []
        }

        #expect(history.items.map(\.id) == [10])
    }

    @Test func refreshResetsPaginationAndDiscardsOldPageInFlight() async {
        let history = RecentlyConsumed()
        await history.fetchItems { [InventoryItem.mock(id: 10)] }
        await history.loadMore { _ in [] }
        #expect(!history.hasMoreData)

        await history.fetchItems { [InventoryItem.mock(id: 20)] }
        #expect(history.hasMoreData)

        await history.loadMore { _ in
            await history.fetchItems { [] }
            return [InventoryItem.mock(id: 10)]
        }
        #expect(history.items.isEmpty)
        #expect(!history.isLoadingMore)
    }
}
