import Foundation
import Models
import Network
import Notifications
import SwiftUI

public enum ShoppingMode {
    case initial, active, completed
}

@Observable
@MainActor
public final class Shopping {
    public var items: [ShoppingItem] = [] {
        didSet {
            updateCaches()
        }
    }

    public var state: FetchState = .loading

    public var shoppingMode: ShoppingMode = .initial
    public var shoppingModeStartDate: Date? {
        didSet {
            if let date = shoppingModeStartDate {
                UserDefaults.standard.set(date, forKey: timerKey)
            } else {
                UserDefaults.standard.removeObject(forKey: timerKey)
            }
        }
    }

    private let timerKey = "shoppingModeStartDate"

    let api = KeepFreshAPI()
    private let cache = ShoppingCache.shared
    private var tempIdCounter: Int = -1

    public private(set) var itemsByStorageLocation: [StorageLocation: [ShoppingItem]] = [:]
    public private(set) var itemsWithoutStorageLocation: [ShoppingItem] = []
    public private(set) var categoriesByStorageLocation: [StorageLocation: [CategoryDetails]] = [:]

    // MARK: - Shopping Mode

    public var upNextStorageLocation: StorageLocation? {
        for location in StorageLocation.allCases {
            if let items = itemsByStorageLocation[location],
               items.contains(where: { $0.status == .created })
            {
                return location
            }
        }
        return nil
    }

    public var upNextItem: ShoppingItem? {
        guard let location = upNextStorageLocation,
              let items = itemsByStorageLocation[location]
        else {
            return nil
        }
        return items.first(where: { $0.status == .created })
    }

    public func shoppingModeItems(for storageLocation: StorageLocation, category: CategoryDetails) -> [ShoppingItem] {
        let locationItems = itemsByStorageLocation[storageLocation] ?? []
        return locationItems.filter {
            $0.product?.category.id == category.id &&
                $0.id != upNextItem?.id &&
                $0.status == .created
        }
    }

    // MARK: - Pending Items

    public var pendingItems: [ShoppingItem] {
        items.filter { $0.status == .pendingCompletion }
    }

    public var hasPendingItems: Bool {
        items.contains { $0.status == .pendingCompletion }
    }

    public func markItemPendingCompletion(id: Int, expiryDate: Date? = nil) {
        guard let index = findItem(id: id) else { return }

        items[index].status = .pendingCompletion

        if let expiryDate {
            items[index].expiryDate = expiryDate
        }
    }

    public func resetShoppingModeItems() {
        for index in items.indices {
            if items[index].status == .pendingCompletion {
                items[index].status = .created
                items[index].expiryDate = nil
            }
        }
        shoppingModeStartDate = nil
    }

    public init(items: [ShoppingItem] = []) {
        self.items = cache.load()
        if self.items.isEmpty {
            self.items = items
        } else {
            state = .loaded
        }
        updateCaches()

        loadShoppingModeStartDate()
        resumeShoppingModeIfNeeded()
    }

    private func loadShoppingModeStartDate() {
        shoppingModeStartDate = UserDefaults.standard.object(forKey: timerKey) as? Date
    }

    private func resumeShoppingModeIfNeeded() {
        if hasPendingItems {
            shoppingMode = .active
            if shoppingModeStartDate == nil {
                shoppingModeStartDate = Date()
            }
        }
    }

    private func updateCaches() {
        itemsByStorageLocation = Dictionary(
            grouping: items.filter { $0.storageLocation != nil },
            by: \.storageLocation!)
        itemsWithoutStorageLocation = items.filter { $0.storageLocation == nil }

        var categoriesCache: [StorageLocation: [CategoryDetails]] = [:]
        for (location, locationItems) in itemsByStorageLocation {
            var seenIds = Set<Int>()
            var categories: [CategoryDetails] = []
            for item in locationItems {
                if let category = item.product?.category, !seenIds.contains(category.id) {
                    seenIds.insert(category.id)
                    categories.append(category)
                }
            }
            categoriesCache[location] = categories.sorted { $0.name < $1.name }
        }
        categoriesByStorageLocation = categoriesCache

        Task { await cache.save(items) }
    }

    private func findItem(id: Int) -> Int? {
        items.firstIndex(where: { $0.id == id })
    }

    public func findItem(barcode: String) -> ShoppingItem? {
        items.first(where: { $0.product?.barcode == barcode })
    }

    private func mergeItems(local: [ShoppingItem], server: [ShoppingItem]) -> [ShoppingItem] {
        let validLocal = local.filter { $0.id > 0 }
        let tempItems = local.filter { $0.id <= 0 }

        var serverById = Dictionary(uniqueKeysWithValues: server.map { ($0.id, $0) })
        var result: [ShoppingItem] = []

        for localItem in validLocal {
            if let serverItem = serverById[localItem.id] {
                result.append(serverItem.updatedAt > localItem.updatedAt ? serverItem : localItem)
                serverById.removeValue(forKey: localItem.id)
            } else {
                result.append(localItem)
            }
        }

        result.append(contentsOf: serverById.values)
        result.append(contentsOf: tempItems)

        return result
    }

    public func moveItem(
        itemId _: Int,
        fromIndex sourceIndex: Int,
        toIndex destinationIndex: Int,
        in storageLocation: StorageLocation)
    {
        let itemsInLocation = items.filter { $0.storageLocation == storageLocation }
        guard sourceIndex < itemsInLocation.count,
              destinationIndex <= itemsInLocation.count else { return }
        let itemToMove = itemsInLocation[sourceIndex]

        guard let actualIndex = items.firstIndex(where: { $0.id == itemToMove.id }) else { return }

        items.remove(at: actualIndex)

        let itemsBeforeDestination = items.filter { $0.storageLocation == storageLocation }
        let targetIndex = min(destinationIndex, itemsBeforeDestination.count)
        let insertionPoints = items.enumerated().filter { $0.element.storageLocation == storageLocation }.map(\.offset)
        let insertIndex = insertionPoints.count > targetIndex ? insertionPoints[targetIndex] : items.count

        items.insert(itemToMove, at: insertIndex)
    }

    public func moveNonStorageLocationItem(
        itemId _: Int,
        fromIndex sourceIndex: Int,
        toIndex destinationIndex: Int)
    {
        let itemsWithoutLocation = items.filter { $0.storageLocation == nil }
        guard sourceIndex < itemsWithoutLocation.count,
              destinationIndex <= itemsWithoutLocation.count else { return }
        let itemToMove = itemsWithoutLocation[sourceIndex]

        guard let actualIndex = items.firstIndex(where: { $0.id == itemToMove.id }) else { return }

        items.remove(at: actualIndex)

        let itemsBeforeDestination = items.filter { $0.storageLocation == nil }
        let targetIndex = min(destinationIndex, itemsBeforeDestination.count)
        let insertionPoints = items.enumerated().filter { $0.element.storageLocation == nil }.map(\.offset)
        let insertIndex = insertionPoints.count > targetIndex ? insertionPoints[targetIndex] : items.count

        items.insert(itemToMove, at: insertIndex)
    }

    public func moveItem(
        itemId: Int,
        to targetStorageLocation: StorageLocation,
        atIndex targetIndex: Int)
    {
        guard let index = findItem(id: itemId) else { return }

        var item = items[index]
        let sourceLocation = item.storageLocation
        let locationChanged = sourceLocation != targetStorageLocation

        if locationChanged {
            item.storageLocation = targetStorageLocation
            item.updatedAt = Date()
        }

        items.remove(at: index)

        let targetItems = items.filter { $0.storageLocation == targetStorageLocation }
        let safeIndex = min(targetIndex, targetItems.count)
        let insertionPoints = items.enumerated().filter { $0.element.storageLocation == targetStorageLocation }.map(\.offset)
        let insertIndex = insertionPoints.count > safeIndex ? insertionPoints[safeIndex] : items.count

        items.insert(item, at: insertIndex)

        if locationChanged {
            updateItem(id: itemId, request: .init(storageLocation: targetStorageLocation))
        }
    }

    public func fetchItems() async {
        if items.isEmpty {
            state = .loading
        }

        do {
            let serverItems = try await api.getShoppingItems()
            let localItems = items
            items = mergeItems(local: localItems, server: serverItems)
            state = .loaded
        } catch {
            if items.isEmpty {
                state = .error
            }
            print("Failed to fetch shopping items: \(error)")
        }
    }

    @discardableResult
    public func addItem(request: AddShoppingItemRequest, categoryId: Int?) async -> Int? {
        do {
            let newItems = try await api.addShoppingItem(request)

            items.append(contentsOf: newItems)

            let itemId = newItems.last?.id

            guard let categoryId, let productId = request.productId else { return itemId }

            guard SuggestionsCache.shared.getSuggestions(for: categoryId) == nil else {
                return itemId
            }

            let response = try await api.getInventoryPreview(categoryId: categoryId, productId: productId)

            await SuggestionsCache.shared.saveSuggestions(categoryId: categoryId, categorySuggestions: response.suggestions)

            return itemId

        } catch {
            print("Adding shopping item failed with error: \(error)")

            if let urlError = error as? URLError {
                print("URL Error details: \(urlError.localizedDescription)")
            }

            if let httpError = error as? DecodingError {
                print("Decoding error: \(httpError)")
            }

            print("Full error details: \(String(describing: error))")

            return nil
        }
    }

    public func addItemWithoutStorageLocation() {
        let tempId = tempIdCounter
        tempIdCounter -= 1

        let tempItem = ShoppingItem(
            id: tempId,
            title: "",
            createdAt: Date(),
            updatedAt: Date(),
            source: .user,
            status: .created,
            storageLocation: nil,
            product: nil)

        items.append(tempItem)

        Task {
            do {
                let newItems = try await api.addShoppingItem(AddShoppingItemRequest(
                    title: "",
                    source: .user,
                    storageLocation: nil,
                    productId: nil,
                    quantity: nil))

                for item in newItems {
                    if let index = items.firstIndex(where: { $0.uuid == tempItem.uuid }) {
                        items[index].id = item.id
                    }
                }
            } catch {
                print("Adding shopping item failed with error: \(error)")

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

    public func addItem(barcode: String) {
        Task {
            do {
                let newItem = try await api.addShoppingItemByBarcode(barcode: barcode)

                items.append(newItem)

                guard let categoryId = newItem.product?.category.id, let productId = newItem.product?.id else { return }

                guard SuggestionsCache.shared.getSuggestions(for: categoryId) == nil else {
                    return
                }

                let response = try await api.getInventoryPreview(categoryId: categoryId, productId: productId)

                await SuggestionsCache.shared.saveSuggestions(categoryId: categoryId, categorySuggestions: response.suggestions)

            } catch {
                print("Adding shopping item by barcode failed with error: \(error)")

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

    public func updateItem(id: Int, request: UpdateShoppingItemRequest) {
        Task {
            do {
                try await api.updateShoppingItem(for: id, request)
            } catch {
                print("Updating shopping item failed with error: \(error)")

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

    public func updateItemByUUID(uuid: UUID, title: String) {
        guard let index = items.firstIndex(where: { $0.uuid == uuid }) else {
            return
        }

        items[index].title = title

        Task {
            do {
                try await api.updateShoppingItem(
                    for: items[index].id,
                    UpdateShoppingItemRequest(title: title))
            } catch {
                print("Updating shopping item failed with error: \(error)")

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

    public func deleteItemByUUID(uuid: UUID) {
        guard let index = items.firstIndex(where: { $0.uuid == uuid }) else {
            return
        }

        let idToRemove = items[index].id

        items.remove(at: index)

        Task {
            do {
                try await api.deleteGroceryItem(for: idToRemove)
            } catch {
                print("Updating shopping item failed with error: \(error)")

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

    public func updateItemStorageLocation(id: Int, storageLocation: StorageLocation) {
        guard let index = findItem(id: id) else { return }

        items[index].storageLocation = storageLocation
        items[index].updatedAt = Date()

        updateItem(id: id, request: .init(storageLocation: storageLocation))
    }

    public func updateItemTitle(id: Int, title: String) {
        guard let index = findItem(id: id) else { return }

        items[index].title = title

        updateItem(id: id, request: .init(title: title))
    }

    public func updateItemStatus(id: Int, status: ShoppingItemStatus) {
        guard let index = findItem(id: id) else { return }

        items[index].status = status

        updateItem(id: id, request: .init(status: status))
    }

    public func updateItemWithoutStorageLocationStatus(uuid: UUID, to status: ShoppingItemStatus) {
        guard let index = items.firstIndex(where: { $0.uuid == uuid }) else {
            return
        }

        let idToUpdate = items[index].id

        items.remove(at: index)

        updateItem(id: idToUpdate, request: .init(status: status))
    }

    public func deleteItem(id: Int) {
        Task {
            do {
                try await api.deleteGroceryItem(for: id)

                if let index = findItem(id: id) {
                    items.remove(at: index)
                }
            } catch {
                print("error deleting item: \(error)")
                return
            }
        }
    }

    public func markItemAsComplete(
        shoppingItemId: Int,
        expiryDate: Date) async -> InventoryItem?
    {
        guard let index = findItem(id: shoppingItemId) else {
            return nil
        }

        let shoppingItem = items[index]

        items.remove(at: index)

        do {
            let inventoryItem = try await api.completeShoppingItem(for: shoppingItemId, CompleteShoppingItemRequest(expiryDate: expiryDate))

            await PushNotifications.shared.requestPushNotifications()

            return inventoryItem
        } catch {
            print("Adding inventory item failed with error: \(error)")

            if let urlError = error as? URLError {
                print("URL Error details: \(urlError.localizedDescription)")
            }

            if let httpError = error as? DecodingError {
                print("Decoding error: \(httpError)")
            }

            print("Full error details: \(String(describing: error))")

            items.insert(shoppingItem, at: index)

            return nil
        }
    }
}
