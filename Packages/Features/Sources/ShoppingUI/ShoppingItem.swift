import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ShoppingItemView: View {
    @Environment(Router.self) var router

    @State private var isComplete = false

    var shoppingItem: ShoppingItem

    public init(shoppingItem: ShoppingItem) {
        self.shoppingItem = shoppingItem
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                GenmojiView(
                    name: shoppingItem.product.category.icon,
                    fontSize: 35,
                    tint: shoppingItem.storageLocation.backgroundColor)

                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(shoppingItem.product.name)
                                .font(.headline)
                                .foregroundStyle(.blue800)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)

                            HStack(spacing: 4) {
                                Text(shoppingItem.product.brand.name)
                                    .foregroundStyle(shoppingItem.product.brand.color).font(.caption)

                                if let amountUnit = shoppingItem.product.amountUnitFormatted {
                                    Circle()
                                        .frame(width: 3, height: 3)
                                        .foregroundStyle(.gray600)
                                    Text(amountUnit)
                                        .foregroundStyle(.gray600).font(.caption)
                                }
                            }

                        }.frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Toggle("Selected Expiry Date", isOn: $isComplete)
                            .toggleStyle(CheckToggleStyle(customColor: shoppingItem.storageLocation.backgroundColor))
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(.white100)
            .cornerRadius(22)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white100)
        .cornerRadius(22)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
    }
}
