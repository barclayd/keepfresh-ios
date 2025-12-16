import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

struct ExpiryDateMinusButton: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    init(date: Binding<Date>, storageLocation: StorageLocation) {
        self._date = date
        self.storageLocation = storageLocation
    }

    var body: some View {
        Button(action: {
            minusTrigger += 1
            date.addDays(-1)
        }) {
            Image(systemName: "minus.square.fill")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.decrease, trigger: minusTrigger)
        .buttonRepeatBehavior(.enabled)
    }
}

struct ExpiryDatePlusButton: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    init(date: Binding<Date>, storageLocation: StorageLocation) {
        self._date = date
        self.storageLocation = storageLocation
    }

    var body: some View {
        Button(action: {
            plusTrigger += 1
            date.addDays(1)
        }) {
            Image(systemName: "plus.square.fill")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.increase, trigger: plusTrigger)
        .buttonRepeatBehavior(.enabled)
    }
}

struct ExpiryDateButtons: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    init(date: Binding<Date>, storageLocation: StorageLocation) {
        self._date = date
        self.storageLocation = storageLocation
    }

    var body: some View {
        VStack {
            Button(action: {
                plusTrigger += 1
                date.addDays(1)
            }) {
                Image(systemName: "plus.square.fill")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
            }
            .buttonStyle(.borderless)
            .sensoryFeedback(.increase, trigger: plusTrigger)
            .buttonRepeatBehavior(.enabled)

            Button(action: {
                minusTrigger += 1
                date.addDays(-1)
            }) {
                Image(systemName: "minus.square.fill")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
            }
            .buttonStyle(.borderless)
            .sensoryFeedback(.decrease, trigger: minusTrigger)
            .buttonRepeatBehavior(.enabled)
        }
    }
}

public struct ShoppingModeActiveItem: View {
    @Environment(Router.self) var router

    @State private var status: ShoppingItemStatus = .created

    // change this to follow what is shown in sheet when item is tapped
    @State private var expiryDate: Date = .init()

    @State private var showDatePicker = false

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
//                    router.presentedSheet = .addInventoryItemFromShopping(shoppingItem)
                } else {
                    status = .created
                }
            }
        )
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
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

//                        Spacer()

                        if let storageLocation = shoppingItem.storageLocation {
                            HStack(spacing: 4) {
                                ExpiryDateMinusButton(date: $expiryDate, storageLocation: storageLocation)
                                
                                Button {
                                    showDatePicker.toggle()
                                } label: {
                                    Text(expiryDate, format: .dateTime.day().month(.abbreviated))
                                        .foregroundStyle(.blue700).font(.caption)
                                }
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
//        .onChange(of: router.presentedSheet) { _, newSheet in
//            if case .addInventoryItemFromShopping = newSheet {
//                return
//            }
//
//            status = .created
//        }
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
    }
}
