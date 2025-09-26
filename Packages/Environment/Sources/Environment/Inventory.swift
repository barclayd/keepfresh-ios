import Models
import Network
import SwiftUI

public enum FetchState {
    case empty
    case loading
    case loaded
    case error
}

@Observable
@MainActor
public final class Inventory {
    public var items: [InventoryItem] = []
    public var state: FetchState = .empty
    
    public init() {}
    
    let api = KeepFreshAPI()
    
    public var itemsByStore: [InventoryStore: [InventoryItem]] {
        var grouped = Dictionary(grouping: items, by: \.storageLocation)
        
        for store in InventoryStore.allCases {
            grouped[store] = grouped[store] ?? []
        }
        
        return grouped
    }
    
    public var itemsSortedByRecentlyAddedDescending: [InventoryItem] {
        items.sorted { $0.createdAt > $1.createdAt }
    }
    
    public var itemsSortedByExpiryDescending: [InventoryItem] {
        items.sorted { $0.expiryDate < $1.expiryDate }
    }
    
    public func fetchItems() async {
        state = .loading
        
        do {
            items = try await api.getInventoryItems().inventoryItems
            print("item length: \(items.count)")
        } catch {
            state = .error
            return
        }
        
        state = .loaded
    }
}
