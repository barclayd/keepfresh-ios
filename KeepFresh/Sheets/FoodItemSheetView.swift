import SwiftUI

let groceryItem: GroceryItem = .init(
    icon: "waterbottle", name: "Semi Skimmed Milk", category: "Dairy", brand: "Sainburys",
    amount: 4, unit: "pints", foodStore: .fridge, status: .open, wasteScore: 17, expiryDate: Date()
)

struct FoodItemSheetView: View {
    var body: some View {
        Text(groceryItem.name)
    }
}
