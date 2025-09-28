import DesignSystem
import SwiftUI

public enum InventoryItemStatus: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    
    case opened
    case discarded
    case consumed
    case unopened
}

public struct UpdateInventoryItemRequest: Codable, Sendable {
    public let status: InventoryItemStatus?
    public let storageLocation: InventoryStore?
    
    public init(status: InventoryItemStatus? = nil, storageLocation: InventoryStore? = nil) {
        self.storageLocation = storageLocation
        self.status = status
    }
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
        
        public init(name: String,
                    brand: String,
                    expiryType: String,
                    storageLocation: String,
                    barcode: String?,
                    unit: String?,
                    amount: Double?,
                    categoryId: Int,
                    sourceId: Int,
                    sourceRef: String)
        {
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
    public init(id: Int, createdAt: Date, updatedAt: Date, openedAt: Date? = nil, status: InventoryItemStatus, storageLocation: InventoryStore, consumptionPrediction: Int, expiryDate: Date, expiryType: ExpiryType, product: Product) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.openedAt = openedAt
        self.status = status
        self.storageLocation = storageLocation
        self.consumptionPrediction = consumptionPrediction
        self.expiryDate = expiryDate
        self.expiryType = expiryType
        self.product = product
    }
    
    public let id: Int
    public let createdAt: Date
    public var updatedAt: Date
    public var openedAt: Date?
    public var status: InventoryItemStatus
    public var storageLocation: InventoryStore
    public let consumptionPrediction: Int
    public let expiryDate: Date
    public let expiryType: ExpiryType
    public let product: Product
}

public struct Product: Codable, Sendable {
    public init(id: Int, name: String, unit: String, brand: Brand, amount: Double, imageUrl: String? = nil, categories: CategoryDetails) {
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
    public let brand: Brand
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

public enum Brand: Codable, Equatable, Hashable, Sendable {
    case tesco
    case sainsburys
    case unknown(String)
    
    private static let brandData: [(Brand, String, Color)] = [
        (.tesco, "Tesco", .brandTesco),
        (.sainsburys, "Sainsbury's", .brandSainsburys),
    ]
    
    private static let knownBrands: [String: Brand] = Dictionary(uniqueKeysWithValues: brandData.map { ($0.1, $0.0) })
    
    private static let brandColors: [Brand: Color] = Dictionary(uniqueKeysWithValues: brandData.map { ($0.0, $0.2) })
    
    private static let brandNames: [Brand: String] = Dictionary(uniqueKeysWithValues: brandData.map { ($0.0, $0.1) })
    
    public var name: String {
        Self.brandNames[self] ?? {
            if case let .unknown(name) = self { return name }
            return "Unknown"
        }()
    }
    
    public var color: Color {
        Self.brandColors[self] ?? .gray
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let brandString = try container.decode(String.self)
        self = Self.knownBrands[brandString] ?? .unknown(brandString)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}
