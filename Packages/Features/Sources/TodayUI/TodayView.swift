import DesignSystem
import Environment
import Models
import SwiftUI

public struct TodayView: View {
    public init() {}

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(Inventory.self) var inventory

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
            LazyVStack(spacing: 14) {
                ForEach(inventory.itemsSortedByExpiryDescending) { inventoryItem in
                    InventoryItemView(
                        inventoryItem: inventoryItem
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
        .background(.white200)
    }
}
