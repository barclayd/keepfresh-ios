import CoreTransferable
import Foundation
import UniformTypeIdentifiers

public enum ShoppingItemStatus: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case created
    case pendingCompletion
    case completed
}

public enum ShoppingItemSource: String, Codable, Sendable {
    case user
    case ai
}

public struct ShoppingItem: Codable, Sendable, Identifiable, Hashable, Transferable {
    public init(
        id: Int,
        title: String?,
        createdAt: Date,
        updatedAt: Date,
        source: ShoppingItemSource,
        status: ShoppingItemStatus,
        storageLocation: StorageLocation?,
        product: Product?)
    {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
        self.status = status
        self.storageLocation = storageLocation
        self.product = product
    }

    public let id: Int
    public var title: String?
    public let createdAt: Date
    public var updatedAt: Date
    public let source: ShoppingItemSource
    public var status: ShoppingItemStatus
    public var storageLocation: StorageLocation?
    public let product: Product?

    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .shoppingItem)
    }
}

extension UTType {
    static var shoppingItem: UTType {
        UTType(exportedAs: "dev.danbarclay.keepfresh.shopping-item")
    }
}

public struct AddShoppingItemRequest: Codable, Sendable {
    public let title: String?
    public let source: ShoppingItemSource
    public let storageLocation: StorageLocation?
    public let productId: Int?
    public let quantity: Int?

    public init(
        title: String?,
        source: ShoppingItemSource,
        storageLocation: StorageLocation?,
        productId: Int?,
        quantity: Int?)
    {
        self.title = title
        self.source = source
        self.storageLocation = storageLocation
        self.productId = productId
        self.quantity = quantity
    }
}

public struct UpdateShoppingItemRequest: Codable, Sendable {
    public let title: String?
    public let status: ShoppingItemStatus?
    public let storageLocation: StorageLocation?

    public init(
        title: String? = nil,
        status: ShoppingItemStatus? = nil,
        storageLocation: StorageLocation? = nil)
    {
        self.title = title
        self.status = status
        self.storageLocation = storageLocation
    }
}
