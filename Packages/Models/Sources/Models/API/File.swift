import Foundation

public enum ShoppingListItemStatus: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case added
    case discarded
    case consumed
    case unopened
}

public enum ShoppingListItemSource : Codable, Sendable {
    case userAdded
    case aiSuggested
}


public struct ShoppingListItem: Codable, Sendable, Identifiable, Hashable {
    public init(
        id: Int,
        createdAt: Date,
        updatedAt: Date,
        source: ShoppingListItemSource,
        status: ShoppingListItemStatus,
        storageLocation: StorageLocation,
        product: Product)
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
        self.status = status
        self.storageLocation = storageLocation
        self.product = product
    }

    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let source: ShoppingListItemSource
    public let status: ShoppingListItemStatus
    public let storageLocation: StorageLocation
    public let product: Product
}
