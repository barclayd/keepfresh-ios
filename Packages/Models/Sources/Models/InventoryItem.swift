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
