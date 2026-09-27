@testable import Environment
import Foundation
import Models
import Testing

@Suite(.serialized)
@MainActor
struct CacheRefreshTests {
    private func item(_ id: Int, status: ShoppingItemStatus = .created) -> ShoppingItem {
        ShoppingItem(
            id: id, title: nil, createdAt: Date(), updatedAt: Date(),
            source: .user, status: status, storageLocation: .pantry, product: InventoryItem.mock.product)
    }

    @Test func shoppingRefreshRemovesOldAccountItemsIncludingPendingOnes() async {
        let shopping = Shopping()
        shopping.items = [item(601, status: .pendingCompletion), item(602)]

        await shopping.fetchItems { [item(634)] }

        #expect(shopping.items.map(\.id) == [634])
    }

    @Test func emptyShoppingResponseClearsSavedItemsButPreservesDrafts() async {
        let shopping = Shopping()
        shopping.items = [item(601), item(-1)]

        await shopping.fetchItems { [] }

        #expect(shopping.items.map(\.id) == [-1])
    }

    @Test func shoppingRefreshPreservesPendingSelectionForCurrentAccount() async {
        let shopping = Shopping()
        let pending = item(601, status: .pendingCompletion)
        shopping.items = [pending]

        await shopping.fetchItems { [item(601)] }

        #expect(shopping.items == [pending])
    }

    @Test func shoppingRefreshKeepsConcurrentAddsAndDoesNotRestoreRemovedItems() async {
        let shopping = Shopping()
        shopping.items = [item(601)]

        await shopping.fetchItems {
            shopping.items = [item(634)]
            return [item(601)]
        }

        #expect(shopping.items.map(\.id) == [634])
    }

    @Test func failedShoppingRefreshKeepsOfflineData() async {
        let shopping = Shopping()
        let cached = item(601)
        shopping.items = [cached]

        await shopping.fetchItems { throw URLError(.notConnectedToInternet) }

        #expect(shopping.items == [cached])
    }

    @Test func olderShoppingResponseCannotOverrideNewerRefresh() async {
        let shopping = Shopping()
        shopping.items = [item(601)]

        await shopping.fetchItems {
            await shopping.fetchItems { [item(634)] }
            return [item(601)]
        }

        #expect(shopping.items.map(\.id) == [634])
    }

    @Test func inventoryRefreshRemovesOldAccountItems() async {
        let inventory = Inventory()
        inventory.items = [InventoryItem.mock(id: 624)]

        await inventory.fetchItems { [InventoryItem.mock(id: 700)] }

        #expect(inventory.items.map(\.id) == [700])
    }

    @Test func emptyInventoryResponseClearsCachedItems() async {
        let inventory = Inventory()
        inventory.items = [InventoryItem.mock(id: 624)]

        await inventory.fetchItems { [] }

        #expect(inventory.items.isEmpty)
    }

    @Test func inventoryRefreshKeepsConcurrentAddsAndDoesNotRestoreRemovedItems() async {
        let inventory = Inventory()
        inventory.items = [InventoryItem.mock(id: 624)]

        await inventory.fetchItems {
            inventory.items = [InventoryItem.mock(id: 700)]
            return [InventoryItem.mock(id: 624)]
        }

        #expect(inventory.items.map(\.id) == [700])
    }

    @Test func failedInventoryRefreshKeepsOfflineData() async {
        let inventory = Inventory()
        let cached = InventoryItem.mock(id: 624)
        inventory.items = [cached]

        await inventory.fetchItems { throw URLError(.notConnectedToInternet) }

        #expect(inventory.items == [cached])
    }

    @Test func olderInventoryResponseCannotOverrideNewerRefresh() async {
        let inventory = Inventory()
        inventory.items = [InventoryItem.mock(id: 624)]

        await inventory.fetchItems {
            await inventory.fetchItems { [InventoryItem.mock(id: 700)] }
            return [InventoryItem.mock(id: 624)]
        }

        #expect(inventory.items.map(\.id) == [700])
    }
}
