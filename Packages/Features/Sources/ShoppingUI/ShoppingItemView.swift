import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ShoppingItemView: View {
    @Environment(Router.self) var router

    @State private var status: ShoppingItemStatus = .created

    var shoppingItem: ShoppingItem

    public init(shoppingItem: ShoppingItem) {
        self.shoppingItem = shoppingItem
    }

    private var isSetToComplete: Binding<Bool> {
        Binding(
            get: {
                status == .pendingCompletion || status == .completed
            },
            set: { newValue in
                if newValue {
                    status = .pendingCompletion
                    router.presentedSheet = .addInventoryItemFromShopping(shoppingItem)
                } else {
                    status = .created
                }
            })
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                if let icon = shoppingItem.product?.category.icon {
                    GenmojiView(
                        name: icon,
                        fontSize: 35,
                        tint: shoppingItem.storageLocation?.backgroundColor ?? .gray600)
                }

                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(shoppingItem.title ?? shoppingItem.product?.name ?? "")
                                .font(.headline)
                                .foregroundStyle(.blue800)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)

                            if let product = shoppingItem.product {
                                HStack(spacing: 4) {
                                    Text(product.brand.name)
                                        .foregroundStyle(product.brand.color).font(.caption)

                                    if let amountUnit = product.amountUnitFormatted {
                                        Circle()
                                            .frame(width: 3, height: 3)
                                            .foregroundStyle(.gray600)
                                        Text(amountUnit)
                                            .foregroundStyle(.gray600).font(.caption)
                                    }
                                }
                            }

                        }.frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Toggle("Selected Expiry Date", isOn: isSetToComplete)
                            .toggleStyle(CheckToggleStyle(customColor: shoppingItem.storageLocation?.backgroundColor ?? .gray600))
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(.white100)
            .cornerRadius(22)
            .opacity(status == .created ? 1 : 0.25)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white100)
        .cornerRadius(22)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .onChange(of: router.presentedSheet) { _, newSheet in
            if case .addInventoryItemFromShopping = newSheet {
                return
            }

            status = .created
        }
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
    }
}
