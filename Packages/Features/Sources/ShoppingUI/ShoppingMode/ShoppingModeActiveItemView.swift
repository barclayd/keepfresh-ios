import Environment
import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ShoppingModeActiveItem: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    let itemId: Int
    var animation: Namespace.ID

    @State private var isAnimatingCompletion = false

    @State private var showDatePicker = false

    @State private var verticalOffset: CGFloat = 0
    @State private var fadeOpacity: CGFloat = 1

    @State private var dismissTask: Task<Void, Never>?

    public init(itemId: Int, animation: Namespace.ID) {
        self.itemId = itemId
        self.animation = animation
    }

    private var shoppingItem: ShoppingItem? {
        shopping.items.first { $0.id == itemId }
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
            })
    }

    private var expiryDate: Binding<Date> {
        Binding(
            get: { shoppingItem?.expiryDate ?? Date() },
            set: { shopping.updateItemExpiryDate(id: itemId, expiryDate: $0) })
    }

    private func triggerDismissAnimation() {
        dismissTask?.cancel()

        dismissTask = Task {
            guard !Task.isCancelled else {
                return
            }

            withAnimation(.smooth(duration: 0.8)) {
                verticalOffset = -100
                fadeOpacity = 0
            }

            try? await Task.sleep(for: .seconds(0.8))

            shopping.markItemPendingCompletion(id: itemId, expiryDate: shoppingItem?.expiryDate)
        }
    }

    public var body: some View {
        if let item = shoppingItem {
            VStack(alignment: .center, spacing: 0) {
                HStack(spacing: 0) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title ?? item.product?.name.truncated(to: 26) ?? "")
                                    .font(.headline)
                                    .foregroundStyle(.blue800)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)

                                if let product = item.product {
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

                            if let storageLocation = item.storageLocation {
                                HStack(spacing: 4) {
                                    ExpiryDateMinusButton(date: expiryDate, storageLocation: storageLocation)

                                    Button {
                                        showDatePicker.toggle()
                                    } label: {
                                        Text(expiryDate.wrappedValue, format: .dateTime.day().month(.abbreviated))
                                            .foregroundStyle(.blue700).font(.caption)
                                            .contentTransition(.numericText())
                                            .animation(.default, value: expiryDate.wrappedValue)
                                    }
                                    .buttonStyle(.borderless)
                                    .padding(.vertical, 5).padding(.horizontal, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.gray200))
                                    .popover(isPresented: $showDatePicker) {
                                        DatePicker(
                                            "Expiry",
                                            selection: expiryDate,
                                            displayedComponents: [.date])
                                            .datePickerStyle(.graphical)
                                            .labelsHidden()
                                            .frame(minWidth: 320)
                                            .tint(.blue700)
                                            .padding(.horizontal, 5)
                                            .presentationCompactAdaptation(.popover)
                                    }

                                    ExpiryDatePlusButton(date: expiryDate, storageLocation: storageLocation)
                                }
                            }

                            Toggle("Selected Expiry Date", isOn: isSetToComplete)
                                .toggleStyle(CheckToggleStyle(customColor: item.storageLocation?.backgroundColor ?? .gray600))
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
            .matchedGeometryEffect(id: item.id, in: animation)
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
            .background(.white100)
            .cornerRadius(22)
            .frame(maxWidth: .infinity, alignment: .center)
            .shadow(color: .shadow, radius: 2, x: 0, y: 4)
            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
            .onChange(of: itemId) { _, _ in
                isAnimatingCompletion = false
                fadeOpacity = 1
            }
        }
    }
}
