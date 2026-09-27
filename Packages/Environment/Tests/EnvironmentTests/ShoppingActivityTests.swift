import Foundation
import Models
import Testing

struct ShoppingActivityTests {
    private func item(
        _ id: Int,
        location: StorageLocation? = .pantry,
        status: ShoppingItemStatus = .created,
        title: String = "Bread") -> ShoppingItem
    {
        ShoppingItem(
            id: id,
            title: title,
            createdAt: .now,
            updatedAt: .now,
            source: .user,
            status: status,
            storageLocation: location,
            product: nil,
            expiryDate: Date(timeIntervalSince1970: 1_800_000_000))
    }

    @Test func followsStorageOrderAndKeepsOrderWithinEachSection() {
        let state = ShoppingActivityAttributes.ContentState(items: [
            item(5, location: nil), item(4, location: .freezer), item(3, location: .fridge), item(2), item(1),
        ])
        #expect(state.current?.id == 2)
        #expect(state.next?.id == 1)
        #expect(state.totalCount == 5)
    }

    @Test func otherItemsAreReachableAfterFood() {
        let state = ShoppingActivityAttributes.ContentState(items: [item(1, status: .pendingCompletion), item(2, location: nil)])
        #expect(state.current?.id == 2)
        #expect(state.current?.storageLocation == nil)
        #expect(state.progress == 0.5)
    }

    @Test func repeatedPickupCannotCollectTheNextItem() {
        var items = [item(1), item(2)]
        var session = ShoppingActivityController.Session(id: "shop", startedAt: .now)
        #expect(session.changeBasket(sessionID: "shop", itemID: 1, undo: false, items: &items))
        #expect(!session.changeBasket(sessionID: "shop", itemID: 1, undo: false, items: &items))
        #expect(items[0].status == .pendingCompletion)
        #expect(items[1].status == .created)
        #expect(ShoppingActivityAttributes.ContentState(items: items).current?.id == 2)
    }

    @Test func oldSessionAndDeletedItemActionsAreIgnored() {
        var items = [item(1)]
        var session = ShoppingActivityController.Session(id: "new", startedAt: .now)
        #expect(!session.changeBasket(sessionID: "old", itemID: 1, undo: false, items: &items))
        #expect(!session.changeBasket(sessionID: "new", itemID: 99, undo: false, items: &items))
        #expect(items[0].status == .created)
    }

    @Test func unsyncedDraftCannotBeCollectedByAStaleIdentifier() {
        var items = [item(-1)]
        var session = ShoppingActivityController.Session(id: "shop", startedAt: .now)
        #expect(!session.changeBasket(sessionID: "shop", itemID: -1, undo: false, items: &items))
        #expect(items[0].status == .created)
    }

    @Test @MainActor func pickupAndUndoSurviveReloadingTheCache() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: url) }
        let cache = ShoppingCache(fileURL: url)
        var items = [item(1), item(2)]
        var session = ShoppingActivityController.Session(id: "shop", startedAt: .now)
        _ = session.changeBasket(sessionID: "shop", itemID: 1, undo: false, items: &items)
        try cache.saveImmediately(items)
        #expect(ShoppingCache(fileURL: url).load()[0].status == .pendingCompletion)
        _ = session.changeBasket(sessionID: "shop", itemID: 1, undo: true, items: &items)
        try cache.saveImmediately(items)
        #expect(ShoppingCache(fileURL: url).load()[0].status == .created)
    }

    @Test func undoRestoresOnlyMostRecentPickupAndPreservesExpiry() {
        var items = [item(1), item(2)]
        let expiry = items[1].expiryDate
        var session = ShoppingActivityController.Session(id: "shop", startedAt: .now)
        _ = session.changeBasket(sessionID: "shop", itemID: 1, undo: false, items: &items)
        _ = session.changeBasket(sessionID: "shop", itemID: 2, undo: false, items: &items)
        #expect(!session.changeBasket(sessionID: "shop", itemID: 1, undo: true, items: &items))
        #expect(session.changeBasket(sessionID: "shop", itemID: 2, undo: true, items: &items))
        #expect(items[0].status == .pendingCompletion)
        #expect(items[1].status == .created)
        #expect(items[1].expiryDate == expiry)
        #expect(session.lastCollectedID == nil)
    }

    @Test func completeAndEmptyListsHaveSafeProgress() {
        let completed = ShoppingActivityAttributes.ContentState(items: [item(1, status: .pendingCompletion)])
        #expect(completed.isComplete)
        #expect(completed.current == nil)
        #expect(completed.progress == 1)
        let empty = ShoppingActivityAttributes.ContentState(items: [])
        #expect(!empty.isComplete)
        #expect(empty.progress == 0)
        #expect(empty.remainingCount == 0)
    }

    @Test func ignoresCompletedAndBlankDrafts() {
        let state = ShoppingActivityAttributes.ContentState(items: [item(1, status: .completed), item(-1, title: "  "), item(2)])
        #expect(state.totalCount == 1)
        #expect(state.current?.id == 2)
    }

    @Test func contentFitsActivityKitBudgetEvenWithVeryLongTitles() throws {
        let items = (1...500).map { item($0, title: String(repeating: "🍞", count: 1000)) }
        let state = ShoppingActivityAttributes.ContentState(items: items)
        let data = try JSONEncoder().encode(state)
        #expect(data.count < 3800)
        #expect(state.totalCount == 500)
        #expect(state.current?.title.count == 120)
    }

    @Test func metadataOmitsBlankBrands() {
        let product = Product(
            id: 1,
            name: "Milk",
            unit: "ml",
            brand: .unknown("  "),
            barcode: nil,
            amount: 500,
            category: .init(icon: "milk", id: 1, name: "Milk", pathDisplay: "Milk", expiryType: .UseBy))
        let shoppingItem = ShoppingItem(
            id: 1,
            title: nil,
            createdAt: .now,
            updatedAt: .now,
            source: .user,
            status: .created,
            storageLocation: .fridge,
            product: product)
        let descriptor = ShoppingActivityAttributes.Item(shoppingItem)
        #expect(descriptor.brand == nil)
        #expect(descriptor.detail == "500ml")
    }

    @Test func fullProductMetadataStillFitsActivityKitBudget() throws {
        let longText = String(repeating: "🍞", count: 1000)
        let product = Product(
            id: 1,
            name: longText,
            unit: longText,
            brand: .unknown(longText),
            barcode: nil,
            amount: nil,
            category: .init(icon: "bread", id: 1, name: "Bread", pathDisplay: "Bread", expiryType: .UseBy))
        let items = (1...3).map { id in
            ShoppingItem(
                id: id,
                title: nil,
                createdAt: .now,
                updatedAt: .now,
                source: .user,
                status: id == 1 ? .pendingCompletion : .created,
                storageLocation: .pantry,
                product: product)
        }
        var state = ShoppingActivityAttributes.ContentState(items: items, lastCollectedID: 1)
        let filename = ShoppingActivityImages.fileName(for: "bread")
        state.current?.imageName = filename
        state.next?.imageName = filename
        state.lastCollected?.imageName = filename
        #expect(try JSONEncoder().encode(state).count < 3800)
    }
}
