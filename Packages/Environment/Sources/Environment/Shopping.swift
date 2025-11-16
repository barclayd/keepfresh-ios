import Foundation
import Network
import Models
import SwiftUI

@Observable
@MainActor
public final class Shopping {
    public var items: [ShoppingItem] = [] {
        didSet {
            updateCaches()
        }
    }
    
    public var state: FetchState = .empty

    public private(set) var itemsByStorageLocation: [StorageLocation: [ShoppingItem]] = [:]

    public init(items: [ShoppingItem] = []) {
        self.items = items
        updateCaches()
    }
    
    let api = KeepFreshAPI()

    private func updateCaches() {
        itemsByStorageLocation = Dictionary(grouping: items.filter { $0.storageLocation != nil }, by: \.storageLocation!)
    }

    public func moveItem(itemId: Int, toIndex targetIndex: Int, in storageLocation: StorageLocation) {
        var filteredItems = itemsByStorageLocation[storageLocation] ?? []

        guard let sourceIndex = filteredItems.firstIndex(where: { $0.id == itemId }) else { return }

        if sourceIndex == targetIndex { return }

        let item = filteredItems.remove(at: sourceIndex)

        let adjustedTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        filteredItems.insert(item, at: adjustedTargetIndex)

        items.removeAll { $0.storageLocation == storageLocation }
        items.append(contentsOf: filteredItems)
    }

    public func moveItemToLocation(itemId: Int, to newLocation: StorageLocation, atIndex targetIndex: Int) {
        guard let sourceIndex = items.firstIndex(where: { $0.id == itemId }) else { return }
        let item = items[sourceIndex]

        let updatedItem = ShoppingItem(
            id: item.id,
            title: nil,
            createdAt: item.createdAt,
            updatedAt: Date(),
            source: item.source,
            status: item.status,
            storageLocation: newLocation,
            product: item.product)

        items.remove(at: sourceIndex)

        var targetItems = items.filter { $0.storageLocation == newLocation }

        let safeTargetIndex = min(targetIndex, targetItems.count)
        targetItems.insert(updatedItem, at: safeTargetIndex)

        items.removeAll { $0.storageLocation == newLocation }
        items.append(contentsOf: targetItems)
    }
    
    public func fetchItems() async {
        state = .loading

        do {
            items = try await api.getShoppingItems()
            state = .loaded
        } catch {
            state = .error
        }
    }
    
    public func addItem(
        request: AddShoppingItemRequest)
    {

        Task {
            do {
                let shoppingItems = try await api.addShoppingItem(request)

                items.append(contentsOf: shoppingItems)
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
    
    // see if this can be used to simplify the drag and drop logic
    public func updateItemStorageLocation(id: Int, storageLocation: StorageLocation) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].storageLocation = storageLocation
        items[index].updatedAt = Date()
    }
    
    public func updateItemTitle(id: Int, title: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].title = title
    }
    
    public func updateItemStatus(id: Int, status: ShoppingItemStatus) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].status = status
    }
}
