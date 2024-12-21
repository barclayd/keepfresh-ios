import Foundation

public enum FoodStore: String, Codable {
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"
}

public enum FoodStatus: String, Codable {
    case open = "Open"
    case binned = "Binned"
    case consumed = "Consumed"
    case unopened = "Unopened"
}

public struct GroceryItem: Identifiable {
    public init(id: UUID, icon: String, name: String, category: String, brand: String, amount: Double, unit: String, foodStore: FoodStore, status: FoodStatus, wasteScore: Double, expiryDate: Date? = nil) {
        self.id = id
        self.icon = icon
        self.name = name
        self.category = category
        self.brand = brand
        self.amount = amount
        self.unit = unit
        self.foodStore = foodStore
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
    public let foodStore: FoodStore
    public let status: FoodStatus
    public let wasteScore: Double
    public let expiryDate: Date?
}
