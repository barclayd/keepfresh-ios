import Foundation

public enum InventoryItemStatus: String, Codable, Identifiable, CaseIterable {
    public var id: Self { self }

    case open
    case binned
    case consumed
    case unopened
}

public struct AddInventoryItemRequest: Codable, Sendable {
    public let item: InventoryItem
    public let product: ProductData

    public init(item: InventoryItem, product: ProductData) {
        self.item = item
        self.product = product
    }

    public struct InventoryItem: Codable, Sendable {
        public let expiryDate: String?
        public let storageLocation: String
        public let status: String
        public let expiryType: String

        public init(expiryDate: String?, storageLocation: String, status: String, expiryType: String) {
            self.expiryDate = expiryDate
            self.storageLocation = storageLocation
            self.status = status
            self.expiryType = expiryType
        }
    }

    public struct ProductData: Codable, Sendable {
        public let name: String
        public let brand: String
        public let expiryType: String
        public let storageLocation: String
        public let barcode: String?
        public let unit: String?
        public let amount: Double?
        public let categoryId: Int
        public let sourceId: Int
        public let sourceRef: String

        public init(
            name: String,
            brand: String,
            expiryType: String,
            storageLocation: String,
            barcode: String?,
            unit: String?,
            amount: Double?,
            categoryId: Int,
            sourceId: Int,
            sourceRef: String
        ) {
            self.name = name
            self.brand = brand
            self.expiryType = expiryType
            self.storageLocation = storageLocation
            self.barcode = barcode
            self.unit = unit
            self.amount = amount
            self.categoryId = categoryId
            self.sourceId = sourceId
            self.sourceRef = sourceRef
        }
    }
}

public struct AddInventoryItemResponse: Codable, Sendable {
    public let inventoryItemId: Int
}

public struct InventoryItemsResponse: Codable, Sendable {
    public let inventoryItems: [InventoryItem]
}

public struct InventoryItem: Codable, Sendable, Identifiable {
    public init(id: Int, createdAt: Date, openedAt: String? = nil, status: String, storageLocation: InventoryStore, consumptionPrediction: Int, expiryDate: Date, expiryType: ExpiryType, products: ProductDetails) {
        self.id = id
        self.createdAt = createdAt
        self.openedAt = openedAt
        self.status = status
        self.storageLocation = storageLocation
        self.consumptionPrediction = consumptionPrediction
        self.expiryDate = expiryDate
        self.expiryType = expiryType
        self.products = products
    }

    public let id: Int
    public let createdAt: Date
    public let openedAt: String?
    public let status: String
    public let storageLocation: InventoryStore
    public let consumptionPrediction: Int
    public let expiryDate: Date
    public let expiryType: ExpiryType
    public let products: ProductDetails
}

public struct ProductDetails: Codable, Sendable {
    public init(id: Int, name: String, unit: String, brand: String, amount: Double, imageUrl: String? = nil, categories: CategoryDetails) {
        self.id = id
        self.name = name
        self.unit = unit
        self.brand = brand
        self.amount = amount
        self.imageUrl = imageUrl
        self.categories = categories
    }

    public let id: Int
    public let name: String
    public let unit: String
    public let brand: String
    public let amount: Double
    public let imageUrl: String?
    public let categories: CategoryDetails
}

public struct CategoryDetails: Codable, Sendable {
    public init(icon: String? = nil, name: String, imageUrl: String? = nil, pathDisplay: String) {
        self.icon = icon
        self.name = name
        self.imageUrl = imageUrl
        self.pathDisplay = pathDisplay
    }

    public let icon: String?
    public let name: String
    public let imageUrl: String?
    public let pathDisplay: String
}
