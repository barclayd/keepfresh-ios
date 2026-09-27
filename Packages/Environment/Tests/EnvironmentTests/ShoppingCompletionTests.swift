import Foundation
import Models
import Testing
@testable import Environment

@Suite(.serialized)
@MainActor
struct ShoppingCompletionTests {
    private func item(_ id: Int) -> ShoppingItem {
        ShoppingItem(
            id: id, title: nil, createdAt: Date(), updatedAt: Date(),
            source: .user, status: .created, storageLocation: .fridge,
            product: InventoryItem.mock.product)
    }

    private func shopping(_ items: [ShoppingItem]) -> Shopping {
        let shopping = Shopping()
        shopping.items = items
        return shopping
    }

    @Test func successWaitsForInventoryBeforeRemovingShoppingItem() async throws {
        let shopping = shopping([item(1), item(2)])
        let expiryDate = Date(timeIntervalSince1970: 1_800_000_000)
        let inventoryItem = InventoryItem.mock(id: 101)

        let result = try await shopping.markItemAsComplete(shoppingItemId: 1, expiryDate: expiryDate) { id, request in
            #expect(id == 1)
            #expect(request.expiryDate == expiryDate)
            #expect(shopping.items.map(\.id) == [1, 2])
            return inventoryItem
        }

        #expect(result == inventoryItem)
        #expect(shopping.items.map(\.id) == [2])
    }

    @Test func failurePreservesItemAndAllowsRetry() async throws {
        let shopping = shopping([item(1)])

        await #expect(throws: URLError.self) {
            try await shopping.markItemAsComplete(shoppingItemId: 1, expiryDate: Date()) { _, _ in
                throw URLError(.notConnectedToInternet)
            }
        }
        #expect(shopping.items.map(\.id) == [1])

        _ = try await shopping.markItemAsComplete(shoppingItemId: 1, expiryDate: Date()) { _, _ in
            InventoryItem.mock
        }
        #expect(shopping.items.isEmpty)
    }

    @Test func failureDoesNotRestoreAnOutdatedCopyOrIndex() async {
        let shopping = shopping([item(1), item(2)])

        await #expect(throws: URLError.self) {
            try await shopping.markItemAsComplete(shoppingItemId: 2, expiryDate: Date()) { _, _ in
                shopping.items = [] // A refresh/delete completed while the request was pending.
                throw URLError(.timedOut)
            }
        }
        #expect(shopping.items.isEmpty)
    }

    @Test func successRemovesByIdentityAfterListChanges() async throws {
        let shopping = shopping([item(1), item(2)])

        _ = try await shopping.markItemAsComplete(shoppingItemId: 1, expiryDate: Date()) { _, _ in
            shopping.items.reverse()
            shopping.items.append(item(3))
            return InventoryItem.mock
        }
        #expect(shopping.items.map(\.id) == [2, 3])
    }

    @Test func duplicateSubmissionDoesNotSendAnotherRequest() async throws {
        let shopping = shopping([item(1)])

        _ = try await shopping.markItemAsComplete(shoppingItemId: 1, expiryDate: Date()) { _, _ in
            await #expect(throws: ShoppingCompletionError.alreadyInProgress) {
                try await shopping.markItemAsComplete(shoppingItemId: 1, expiryDate: Date()) { _, _ in
                    Issue.record("A duplicate request reached the API")
                    return InventoryItem.mock
                }
            }
            return InventoryItem.mock
        }
        #expect(shopping.items.isEmpty)
    }

    @Test func unsavedAndMissingItemsDoNotReachTheAPI() async {
        let shopping = shopping([item(-1)])

        for (id, error) in [(-1, ShoppingCompletionError.itemNotSynced), (99, .itemNotFound)] {
            await #expect(throws: error) {
                try await shopping.markItemAsComplete(shoppingItemId: id, expiryDate: Date()) { _, _ in
                    Issue.record("An invalid shopping item reached the API")
                    return InventoryItem.mock
                }
            }
        }
        #expect(shopping.items.map(\.id) == [-1])
    }
}
