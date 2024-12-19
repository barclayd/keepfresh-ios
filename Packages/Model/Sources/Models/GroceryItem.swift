import Foundation

enum FoodStore: String, Codable {
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"
}

enum FoodStatus: String, Codable {
    case open = "Open"
    case binned = "Binned"
    case consumed = "Consumed"
    case unopened = "Unopened"
}

struct GroceryItem: Identifiable {
    let id: UUID
    let icon: String
    let name: String
    let category: String
    let brand: String
    let amount: Double
    let unit: String
    let foodStore: FoodStore
    let status: FoodStatus
    let wasteScore: Double
    let expiryDate: Date?
}
