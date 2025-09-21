import Foundation

public enum InventoryItemStatus: String, Codable, Identifiable, CaseIterable {
    public var id: Self { self }
    
    case open
    case binned
    case consumed
    case unopened
}

public struct InventoryItem: Identifiable {
    public init(
        id: UUID, imageURL: String, name: String, category: String, brand: String, amount: Double,
        unit: String, inventoryStore: InventoryStore, status: InventoryItemStatus, wasteScore: Double,
        expiryDate: Date? = nil
    ) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.category = category
        self.brand = brand
        self.amount = amount
        self.unit = unit
        self.inventoryStore = inventoryStore
        self.status = status
        self.wasteScore = wasteScore
        self.expiryDate = expiryDate
    }
    
    public let id: UUID
    public let imageURL: String
    public let name: String
    public let category: String
    public let brand: String
    public let amount: Double
    public let unit: String
    public let inventoryStore: InventoryStore
    public let status: InventoryItemStatus
    public let wasteScore: Double
    public let expiryDate: Date?
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
