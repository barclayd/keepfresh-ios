import Foundation

public enum InventoryStore: String, Codable, Identifiable, CaseIterable {
    public var id: Self { self }

    case pantry
    case fridge
    case freezer

    public var icon: String {
        switch self {
        case .pantry: return "cabinet"
        case .fridge: return "refrigerator"
        case .freezer: return "snowflake.circle"
        }
    }
}

public struct InventoryStoreDetails: Identifiable, Hashable {
    public init(id: Int, type: InventoryStore, expiryStatusPercentage: Float, lastUpdated: Date, itemsCount: Int, openItemsCount: Int, itemsExpiringSoonCount: Int, recentItemImages: [String]) {
        self.id = id
        self.type = type
        self.expiryStatusPercentage = expiryStatusPercentage
        self.lastUpdated = lastUpdated
        self.itemsCount = itemsCount
        self.openItemsCount = openItemsCount
        self.itemsExpiringSoonCount = itemsExpiringSoonCount
        self.recentItemImages = recentItemImages
    }

    public var id: Int
    public var type: InventoryStore
    public var expiryStatusPercentage: Float
    public var lastUpdated: Date
    public var itemsCount: Int
    public var openItemsCount: Int
    public var itemsExpiringSoonCount: Int
    public var recentItemImages: [String]
}

public enum ConsumableStatus: String, Codable, Identifiable, CaseIterable {
    public var id: Self { self }

    case open
    case binned
    case consumed
    case unopened
}

public struct ConsumableSearchItem: Identifiable, Hashable {
    public init(id: UUID, icon: String, name: String, category: String, brand: String, amount: Double, unit: String) {
        self.id = id
        self.icon = icon
        self.name = name
        self.category = category
        self.brand = brand
        self.amount = amount
        self.unit = unit
    }

    public let id: UUID
    public let icon: String
    public let name: String
    public let category: String
    public let brand: String
    public let amount: Double
    public let unit: String
}

public struct ConsumableItem: Identifiable {
    public init(id: UUID, icon: String, name: String, category: String, brand: String, amount: Double, unit: String, inventoryStore: InventoryStore, status: ConsumableStatus, wasteScore: Double, expiryDate: Date? = nil) {
        self.id = id
        self.icon = icon
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
    public let icon: String
    public let name: String
    public let category: String
    public let brand: String
    public let amount: Double
    public let unit: String
    public let inventoryStore: InventoryStore
    public let status: ConsumableStatus
    public let wasteScore: Double
    public let expiryDate: Date?
}
