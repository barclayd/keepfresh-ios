import Environment
import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ShoppingModeConfirmItemView: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    @State private var isAnimatingCompletion = false

    // change this to follow what is shown in sheet when item is tapped
    @State private var expiryDate: Date = .init()

    @State private var showDatePicker = false

    @State private var verticalOffset: CGFloat = 0
    @State private var fadeOpacity: CGFloat = 1

    @State private var dismissTask: Task<Void, Never>?

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
                    triggerDismissAnimation()
                } else {
                    dismissTask?.cancel()
                    isAnimatingCompletion = false
                }
            }
        )
    }

    private func triggerDismissAnimation() {
        dismissTask?.cancel()

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(1))

            guard !Task.isCancelled else {
                return
            }

            withAnimation(.smooth(duration: 0.6)) {
                verticalOffset = -100
                fadeOpacity = 0
            }

            try? await Task.sleep(for: .seconds(0.6))
            
            shopping.markItemPendingCompletion(id: shoppingItem.id, expiryDate: expiryDate)
        }
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
                            Text(shoppingItem.title ?? shoppingItem.product?.name.truncated(to: 26) ?? "")
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
                                }.fixedSize(horizontal: true, vertical: false)
                            }

                        }.frame(maxWidth: .infinity, alignment: .leading)

                        if let storageLocation = shoppingItem.storageLocation {
                            HStack(spacing: 4) {
                                ExpiryDateMinusButton(date: $expiryDate, storageLocation: storageLocation)

                                Button {
                                    showDatePicker.toggle()
                                } label: {
                                    Text(expiryDate, format: .dateTime.day().month(.abbreviated))
                                        .foregroundStyle(.blue700).font(.caption)
                                        .contentTransition(.numericText())
                                        .animation(.default, value: expiryDate)
                                }
                                .buttonStyle(.borderless)
                                .padding(.vertical, 5).padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.gray200)
                                )
                                .popover(isPresented: $showDatePicker) {
                                    DatePicker(
                                        "Expiry",
                                        selection: $expiryDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .frame(minWidth: 300)
                                    .tint(.blue700)
                                    .padding(.horizontal, 5)
                                    .presentationCompactAdaptation(.popover)
                                }

                                ExpiryDatePlusButton(date: $expiryDate, storageLocation: storageLocation)
                            }
                        }
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
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
        .onChange(of: shoppingItem) { oldShoppingItem, newShoppingItem in
            if (oldShoppingItem.id != newShoppingItem.id) {
                isAnimatingCompletion = false
                fadeOpacity = 1
            }
        }
    }
}
