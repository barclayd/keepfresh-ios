import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ShoppingItemView: View {
    @Environment(Router.self) var router

    @State private var isAnimatingCompletion = false

    var shoppingItem: ShoppingItem
    var animation: Namespace.ID

    public init(shoppingItem: ShoppingItem, animation: Namespace.ID) {
        self.shoppingItem = shoppingItem
        self.animation = animation
    }

    private var isSetToComplete: Binding<Bool> {
        Binding(
            get: { isAnimatingCompletion },
            set: { newValue in
                if newValue {
                    isAnimatingCompletion = true
                    router.presentedSheet = .addInventoryItemFromShopping(shoppingItem)
                } else {
                    isAnimatingCompletion = false
                }
            }
        )
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
                                    if let logoAsset = product.brand.logoAssetName {
                                        Image(logoAsset)
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .clipShape(RoundedRectangle(cornerRadius: product.brand.hasRoundedLogo ? 4 : 0))
                                    }

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
            .opacity(isAnimatingCompletion ? 0.25 : 1)
        }
        .matchedGeometryEffect(id: shoppingItem.id, in: animation)
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

            isAnimatingCompletion = false
        }
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
    }
}
