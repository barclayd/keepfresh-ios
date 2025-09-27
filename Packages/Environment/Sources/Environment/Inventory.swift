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
    public var items: [InventoryItem] = [] {
        didSet {
            updateCaches()
        }
    }
    public var state: FetchState = .empty
    
    let api = KeepFreshAPI()
    
    private(set) public var itemsByLocation: [InventoryStore: [InventoryItem]] = [:]
    private(set) public var productCounts: [Int: Int] = [:]
    private(set) public var productCountsByLocation: [Int: [InventoryStore: Int]] = [:]
    
    public init() {}
    
    private func updateCaches() {
        itemsByLocation = Dictionary(grouping: items, by: \.storageLocation)
        
        var counts: [Int: Int] = [:]
        var locationCounts: [Int: [InventoryStore: Int]] = [:]
        
        for item in items {
            counts[item.products.id, default: 0] += 1
            locationCounts[item.products.id, default: [:]][item.storageLocation, default: 0] += 1
        }
        
        productCounts = counts
        productCountsByLocation = locationCounts
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
