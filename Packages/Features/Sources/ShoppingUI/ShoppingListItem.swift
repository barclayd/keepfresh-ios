import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ShoppingListItemView: View {
    @Environment(Router.self) var router
    
    @State private var isComplete = false

    var shoppingListItem: ShoppingListItem

    public init(shoppingListItem: ShoppingListItem) {
        self.shoppingListItem = shoppingListItem
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                GenmojiView(
                    name: shoppingListItem.product.category.icon,
                    fontSize: 35,
                    tint: shoppingListItem.storageLocation.backgroundColor)

                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(shoppingListItem.product.name)
                                .font(.headline)
                                .foregroundStyle(.blue800)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)

                            HStack(spacing: 4) {
                                Text(shoppingListItem.product.brand.name)
                                    .foregroundStyle(shoppingListItem.product.brand.color).font(.caption)

                                if let amountUnit = shoppingListItem.product.amountUnitFormatted {
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
                            .toggleStyle(CheckToggleStyle(customColor: nil))
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(.white100)
            .cornerRadius(20)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white100)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}
