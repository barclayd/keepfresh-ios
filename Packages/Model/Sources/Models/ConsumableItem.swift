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
