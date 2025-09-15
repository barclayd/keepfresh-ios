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

// MARK: - Inventory Suggestions Service

@MainActor
public class InventorySuggestionsService: ObservableObject {
    private static var globalCache: [Int: InventorySuggestionsResponse] = [:]

    @Published public var isLoading: Bool = false
    @Published public var suggestions: InventorySuggestionsResponse?
    @Published public var error: Error?

    private var currentCategoryId: Int?

    public init() {}

    public func fetchInventorySuggestions(for categoryId: Int) async {
        if currentCategoryId != categoryId {
            currentCategoryId = categoryId
            suggestions = nil
            error = nil
        }

        if let cachedSuggestions = Self.globalCache[categoryId] {
            suggestions = cachedSuggestions
            print("Using cached inventory suggestions for category: \(categoryId)")
            return
        }

        isLoading = true
        error = nil

        do {
            let url = URL(
                string: "https://api.keepfre.sh/v1/categories/\(categoryId)/inventory-suggestions")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(InventorySuggestionsResponse.self, from: data)

            Self.globalCache[categoryId] = response

            if currentCategoryId == categoryId {
                suggestions = response
            }

            print("Fetched inventory suggestions for category: \(categoryId)")

        } catch {
            if currentCategoryId == categoryId {
                self.error = error
            }
            print("Failed to fetch inventory suggestions: \(error)")
        }

        isLoading = false
    }

    public func getCachedSuggestions(for categoryId: Int) -> InventorySuggestionsResponse? {
        return Self.globalCache[categoryId]
    }

    public static func clearGlobalCache() {
        globalCache.removeAll()
    }

    public func reset() {
        currentCategoryId = nil
        suggestions = nil
        error = nil
        isLoading = false
    }
}
