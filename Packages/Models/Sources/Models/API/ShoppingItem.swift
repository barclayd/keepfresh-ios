import CoreTransferable
import Foundation
import UniformTypeIdentifiers

public enum ShoppingItemStatus: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case added
    case pendingDeletion
    case completed
}

public enum ShoppingItemSource: Codable, Sendable {
    case userAdded
    case aiSuggested
}

public struct ShoppingItem: Codable, Sendable, Identifiable, Hashable, Transferable {
    public init(
        id: Int,
        title: String?,
        createdAt: Date,
        updatedAt: Date,
        source: ShoppingItemSource,
        status: ShoppingItemStatus,
        storageLocation: StorageLocation,
        product: Product)
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
    public let title: String?
    public let createdAt: Date
    public let updatedAt: Date
    public let source: ShoppingItemSource
    public let status: ShoppingItemStatus
    public let storageLocation: StorageLocation
    public let product: Product

    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .shoppingItem)
    }
}

extension UTType {
    static var shoppingItem: UTType {
        UTType(exportedAs: "dev.danbarclay.keepfresh.shopping-item")
    }
}
