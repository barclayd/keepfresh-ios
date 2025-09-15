import Foundation
import Models

// MARK: - Inventory Suggestions API Models

public struct InventorySuggestionsResponse: Codable, Equatable {
    public let shelfLifeInDays: ShelfLifeInDays
    public let expiryType: ExpiryType
    public let recommendedStorageLocation: InventoryStore
}

public struct ShelfLifeInDays: Codable, Equatable {
    public let opened: StorageOptions
    public let unopened: StorageOptions
}

extension ShelfLifeInDays {
    subscript(_ status: ProductSearchItemStatus) -> StorageOptions {
        status == .opened ? opened : unopened
    }
}

public struct StorageOptions: Codable, Equatable {
    public let pantry: Int?
    public let fridge: Int?
    public let freezer: Int?
}

extension StorageOptions {
    subscript(_ store: InventoryStore) -> Int? {
        switch store {
        case .pantry: return pantry
        case .fridge: return fridge
        case .freezer: return freezer
        }
    }
}

@MainActor
@Observable
public class InventorySuggestions {
    private static var globalCache: [Int: InventorySuggestionsResponse] = [:]
    
    public enum LoadingState {
        case idle
        case loading
        case loaded(InventorySuggestionsResponse)
        case failed(Error)
    }
    
    public var state: LoadingState = .idle
    
    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    public var suggestions: InventorySuggestionsResponse? {
        if case .loaded(let response) = state { return response }
        return nil
    }
    
    public var error: Error? {
        if case .failed(let error) = state { return error }
        return nil
    }
    
    private var currentCategoryId: Int?
    
    public init() {}
    
    public func fetchInventorySuggestions(for categoryId: Int) async {
        if currentCategoryId != categoryId {
            currentCategoryId = categoryId
            state = .idle
        }
        
        if let cachedSuggestions = Self.globalCache[categoryId] {
            state = .loaded(cachedSuggestions)
            print("Using cached inventory suggestions for category: \(categoryId)")
            return
        }
        
        state = .loading
        
        do {
            let url = URL(
                string: "https://api.keepfre.sh/v1/categories/\(categoryId)/inventory-suggestions")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(InventorySuggestionsResponse.self, from: data)
            
            Self.globalCache[categoryId] = response
            
            if currentCategoryId == categoryId {
                state = .loaded(response)
            }
            
            print("Fetched inventory suggestions for category: \(categoryId)")
            
        } catch {
            if currentCategoryId == categoryId {
                state = .failed(error)
            }
            print("Failed to fetch inventory suggestions: \(error)")
        }
    }
    
    public func getCachedSuggestions(for categoryId: Int) -> InventorySuggestionsResponse? {
        return Self.globalCache[categoryId]
    }
    
    public static func clearGlobalCache() {
        globalCache.removeAll()
    }
    
    public func reset() {
        currentCategoryId = nil
        state = .idle
    }
}
