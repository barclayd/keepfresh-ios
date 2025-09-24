import Foundation

public struct InventorySuggestionsResponse: Codable, Sendable, Equatable {
    public let shelfLifeInDays: ShelfLifeInDays
    public let expiryType: ExpiryType
    public let recommendedStorageLocation: InventoryStore
}

public struct ShelfLifeInDays: Codable, Equatable, Sendable {
    public let opened: StorageOptions
    public let unopened: StorageOptions
}

public extension ShelfLifeInDays {
    subscript(_ status: ProductSearchItemStatus) -> StorageOptions {
        status == .opened ? opened : unopened
    }
}

public struct StorageOptions: Codable, Equatable, Sendable {
    public let pantry: Int?
    public let fridge: Int?
    public let freezer: Int?
}

public extension StorageOptions {
    subscript(_ store: InventoryStore) -> Int? {
        switch store {
        case .pantry: return pantry
        case .fridge: return fridge
        case .freezer: return freezer
        }
    }
}
