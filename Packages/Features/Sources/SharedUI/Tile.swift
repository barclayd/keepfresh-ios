import DesignSystem
import Environment
import Models
import SwiftUI

public struct Tile: View {
    @Environment(Shopping.self) var shopping

    @State private var shoppingItemId: Int?

    let recentlyConsumedInventoryItem: InventoryItem

    public init(recentlyConsumedInventoryItem: InventoryItem) {
        self.recentlyConsumedInventoryItem = recentlyConsumedInventoryItem
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(recentlyConsumedInventoryItem.product.name).foregroundStyle(recentlyConsumedInventoryItem.storageLocation.foregroundColor).font(.headline).fontWeight(.bold)
                .lineLimit(2, reservesSpace: true).padding([.top, .leading], 5)

            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 4) {
                        if let logoAsset = recentlyConsumedInventoryItem.product.brand.logoAssetName {
                            Image(logoAsset)
                                .resizable()
                                .frame(width: 14, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: recentlyConsumedInventoryItem.product.brand.hasRoundedLogo ? 4 : 0))
                        }

                        Text(recentlyConsumedInventoryItem.product.brand.shortName)
                            .foregroundStyle(recentlyConsumedInventoryItem.storageLocation == .freezer ? .white200 : recentlyConsumedInventoryItem.product.brand.color)
                            .font(.caption)
                    }

                    if let amountUnitFormatted = recentlyConsumedInventoryItem.product.amountUnitFormatted {
                        Text(amountUnitFormatted).foregroundStyle(recentlyConsumedInventoryItem.storageLocation == .fridge ? .gray600 : recentlyConsumedInventoryItem.storageLocation.infoColor).font(.caption)
                    }

                    Spacer()

                    Button(action: {
                        if let itemId = shoppingItemId {
                            shoppingItemId = nil
                            shopping.deleteItem(id: itemId)
                        } else {
                            Task {
                                let id = await shopping.addItem(
                                    request: AddShoppingItemRequest(
                                        title: nil,
                                        source: .user,
                                        storageLocation: recentlyConsumedInventoryItem.storageLocation,
                                        productId: recentlyConsumedInventoryItem.product.id,
                                        quantity: 1),
                                    categoryId: recentlyConsumedInventoryItem.product.category.id)
                                shoppingItemId = id
                            }
                        }
                    }) {
                        Image(systemName: shoppingItemId != nil ? "checkmark.circle.fill" : "plus.circle.fill").foregroundStyle(recentlyConsumedInventoryItem.storageLocation.foregroundColor)
                            .font(.system(size: 28))
                            .contentTransition(.symbolEffect(.replace))
                    }
                }.padding(.leading, 5)

                Spacer()

                VStack(alignment: .trailing) {
                    Spacer()
                    GenmojiView(
                        name: recentlyConsumedInventoryItem.product.category.icon,
                        fontSize: 56,
                        tint: recentlyConsumedInventoryItem.product.brand.color).rotationEffect(Angle(degrees: -10))
                }
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 15).frame(width: 170, height: 155)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(
                    stops: recentlyConsumedInventoryItem.storageLocation.viewGradientStopsReversed,
                    startPoint: .leading,
                    endPoint: .trailing)).shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4))
    }
}
