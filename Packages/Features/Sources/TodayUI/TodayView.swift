import DesignSystem
import Models
import SwiftUI

@MainActor let inventoryItem: InventoryItem = .init(id: 1, createdAt: "2025-09-21T19:08:19.525Z", openedAt: nil, status: "unopened", storageLocation: "Fridge", consumptionPrediction: 100, expiryDate: "2025-10-01T00:00:00.000Z", expiryType: "Use By", products: ProductDetails(id: 6, name: "Chicken Thighs", unit: "kg", brand: "Tesco", amount: 1.2, categories: CategoryDetails(name: "Fresh Chicken", pathDisplay: "Fresh Food.Fresh Meat & Poultry.Fresh Chicken")))

public struct TodayView: View {
    public init() {}

    @State private var selectedInventoryItem: InventoryItem? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private func getSheetFraction(height: CGFloat) -> CGFloat {
        if dynamicTypeSize >= .xxLarge {
            return 0.8
        }

        switch height {
        case ..<668:
            return 1 // iPhone SE
        case ..<845:
            return 0.9 // iPhone 13
        case ..<957:
            return 0.85 // iPhone 16 Pro Max
        default:
            return 0.7
        }
    }

    public var body: some View {
        ScrollView {
            InventoryItemView(
                selectedInventoryItem: $selectedInventoryItem, inventoryItem: inventoryItem
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20).padding(.vertical, 10).background(.white200)
    }
}
