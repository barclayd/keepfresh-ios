import Foundation
import Models
import Network
import Notifications
import SwiftUI

@Observable
@MainActor
public final class Shopping {
    public var itemsByStorageLocation: [StorageLocation: [ShoppingItem]] = [:]
    
    public var state: FetchState = .empty
    
    public init(items: [ShoppingItem] = []) {
        itemsByStorageLocation = Dictionary(
            grouping: items.filter { $0.storageLocation != nil },
            by: \.storageLocation!)
    }
    
    let api = KeepFreshAPI()
    
    private func findItem(id: Int) -> (StorageLocation, Int)? {
        for (location, items) in itemsByStorageLocation {
            if let index = items.firstIndex(where: { $0.id == id }) {
                return (location, index)
            }
        }
        return nil
    }
    
    public func moveItem(
        itemId _: Int,
        fromIndex sourceIndex: Int,
        toIndex destinationIndex: Int,
        in storageLocation: StorageLocation)
    {
        guard var items = itemsByStorageLocation[storageLocation],
              sourceIndex < items.count,
              destinationIndex <= items.count else { return }
        
        let item = items.remove(at: sourceIndex)
        items.insert(item, at: destinationIndex)
        
        itemsByStorageLocation[storageLocation] = items
    }
    
    public func moveItem(
        itemId: Int,
        to targetStorageLocation: StorageLocation,
        atIndex targetIndex: Int)
    {
        guard let (sourceLocation, sourceIndex) = findItem(id: itemId) else { return }
        
        var sourceItems = itemsByStorageLocation[sourceLocation] ?? []
        var item = sourceItems.remove(at: sourceIndex)
        itemsByStorageLocation[sourceLocation] = sourceItems.isEmpty ? nil : sourceItems
        
        let locationChanged = sourceLocation != targetStorageLocation
        
        if locationChanged {
            item.storageLocation = targetStorageLocation
            item.updatedAt = Date()
        }
        
        var targetItems = itemsByStorageLocation[targetStorageLocation] ?? []
        let safeIndex = min(targetIndex, targetItems.count)
        targetItems.insert(item, at: safeIndex)
        itemsByStorageLocation[targetStorageLocation] = targetItems
        
        if locationChanged {
            updateItem(id: itemId, request: .init(storageLocation: targetStorageLocation))
        }
    }
    
    public func fetchItems() async {
        state = .loading
        
        do {
            let items = try await api.getShoppingItems()
            itemsByStorageLocation = Dictionary(
                grouping: items.filter { $0.storageLocation != nil },
                by: \.storageLocation!)
            state = .loaded
        } catch {
            state = .error
        }
    }
    
    public func addItem(request: AddShoppingItemRequest, categoryId: Int?) {
        Task {
            do {
                let newItems = try await api.addShoppingItem(request)
                
                for item in newItems where item.storageLocation != nil {
                    let location = item.storageLocation!
                    var locationItems = itemsByStorageLocation[location] ?? []
                    locationItems.append(item)
                    itemsByStorageLocation[location] = locationItems
                }
                
                guard let categoryId, let productId = request.productId else { return }
                
                guard SuggestionsCache.shared.getSuggestions(for: categoryId) == nil else {
                    return
                }
                
                let response = try await api.getInventoryPreview(categoryId: categoryId, productId: productId)
                
                await SuggestionsCache.shared.saveSuggestions(categoryId: categoryId, categorySuggestions: response.suggestions)
                
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
                
                let location = newItem.storageLocation!
                var locationItems = itemsByStorageLocation[location] ?? []
                locationItems.append(newItem)
                itemsByStorageLocation[location] = locationItems
                
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
    
    public func updateItemStorageLocation(id: Int, storageLocation: StorageLocation) {
        guard let (currentLocation, index) = findItem(id: id) else { return }
        
        var currentItems = itemsByStorageLocation[currentLocation] ?? []
        var item = currentItems.remove(at: index)
        itemsByStorageLocation[currentLocation] = currentItems.isEmpty ? nil : currentItems
        
        item.storageLocation = storageLocation
        item.updatedAt = Date()
        
        var targetItems = itemsByStorageLocation[storageLocation] ?? []
        targetItems.append(item)
        itemsByStorageLocation[storageLocation] = targetItems
        
        updateItem(id: id, request: .init(storageLocation: storageLocation))
    }
    
    public func updateItemTitle(id: Int, title: String) {
        guard let (location, index) = findItem(id: id) else { return }
        
        var items = itemsByStorageLocation[location] ?? []
        items[index].title = title
        itemsByStorageLocation[location] = items
        
        updateItem(id: id, request: .init(title: title))
    }
    
    public func updateItemStatus(id: Int, status: ShoppingItemStatus) {
        guard let (location, index) = findItem(id: id) else { return }
        
        var items = itemsByStorageLocation[location] ?? []
        items[index].status = status
        itemsByStorageLocation[location] = items
        
        updateItem(id: id, request: .init(status: status))
    }
    
    public func deleteItem(id: Int) {
        Task {
            do {
                try await api.deleteGroceryItem(for: id)
                
                guard let (sourceLocation, sourceIndex) = findItem(id: id) else { return }
                
                var sourceItems = itemsByStorageLocation[sourceLocation] ?? []
                sourceItems.remove(at: sourceIndex)
                
                itemsByStorageLocation[sourceLocation] = sourceItems.isEmpty ? nil : sourceItems
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
        guard let (sourceLocation, sourceIndex) = findItem(id: shoppingItemId) else {
            return nil
        }
        
        var sourceItems = itemsByStorageLocation[sourceLocation] ?? []
        
        let shoppingItem = sourceItems[sourceIndex]
        
        sourceItems.remove(at: sourceIndex)
        
        itemsByStorageLocation[sourceLocation] = sourceItems.isEmpty ? nil : sourceItems
        
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
            
            sourceItems.insert(shoppingItem, at: sourceIndex)
            
            let location = shoppingItem.storageLocation!
            var locationItems = itemsByStorageLocation[location] ?? []
            locationItems.append(shoppingItem)
            itemsByStorageLocation[location] = locationItems
            
            return nil
        }
    }
}
