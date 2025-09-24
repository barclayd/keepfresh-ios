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
