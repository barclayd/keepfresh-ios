import DesignSystem
import Models
import SwiftUI

@MainActor let consumableItem: InventoryItem = .init(
    id: UUID(), imageURL: "https://keep-fresh-images.s3.eu-west-2.amazonaws.com/milk.png",
    name: "Semi Skimmed Milk", category: "Dairy", brand: "Sainburys", amount: 4, unit: "pts",
    inventoryStore: .fridge, status: .open, wasteScore: 17, expiryDate: Date()
)

public struct TodayView: View {
    public init() {}

    @State private var selectedConsumableItem: InventoryItem? = nil

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
            ConsumableItemView(
                selectedConsumableItem: $selectedConsumableItem, consumableItem: consumableItem
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20).padding(.vertical, 10).background(.white200)
    }
}
