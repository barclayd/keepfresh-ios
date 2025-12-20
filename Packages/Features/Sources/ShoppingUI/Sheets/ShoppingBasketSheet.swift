import DesignSystem
import Environment
import Models
import Network
import Router
import SwiftUI

public struct ShoppingBasketSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(Shopping.self) var shopping
    @Environment(Inventory.self) var inventory

    @State private var presentEndShopAlert = false

    let source: BasketDetailButtonSource

    public init(source: BasketDetailButtonSource) {
        self.source = source
    }

    private var pendingItems: [ShoppingItem] {
        shopping.items.filter { $0.status == .pendingCompletion }
    }

    private var pendingItemsByLocation: [StorageLocation: [ShoppingItem]] {
        Dictionary(
            grouping: pendingItems.filter { $0.storageLocation != nil },
            by: { $0.storageLocation! })
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("^[\(pendingItems.count) item](inflect: true) to be added")
                            .font(.title3)
                            .foregroundStyle(.blue800)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ForEach(StorageLocation.allCases) { location in
                            if let items = pendingItemsByLocation[location], !items.isEmpty {
                                BasketStorageLocationPanel(
                                    storageLocation: location,
                                    items: items)
                            }
                        }

                        if !shopping.itemsWithoutStorageLocation.filter({ $0.status == .pendingCompletion }).isEmpty {
                            OtherBasketStorageLocationPanel()
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 100)
                }
                .overlay(alignment: .bottom) {
                    BottomActionCustomButton(
                        title: "Finish shop",
                        safeAreaInsets: geometry.safeAreaInsets,
                        action: {
                            let request = CreateShoppingSessionRequest(
                                createdAt: shopping.shoppingModeStartDate ?? Date(),
                                updatedAt: Date(),
                                shoppingItems: shopping.pendingItems.map {
                                    ShoppingSessionItem(shoppingItemId: $0.id, expiryDate: $0.expiryDate)
                                })

                            shopping.completeShoppingSession()
                            dismiss()

                            let api = KeepFreshAPI()
                            if let inventoryItems = try? await api.createShoppingSession(request) {
                                inventory.items.append(contentsOf: inventoryItems)
                            }
                        })
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        switch source {
                        case .basket:
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.gray600)
                            }
                            .buttonStyle(.borderless)

                        case .stop:
                            Button {
                                presentEndShopAlert.toggle()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white100)
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.red500)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                let request = CreateShoppingSessionRequest(
                                    createdAt: shopping.shoppingModeStartDate ?? Date(),
                                    updatedAt: Date(),
                                    shoppingItems: shopping.pendingItems.map {
                                        ShoppingSessionItem(shoppingItemId: $0.id, expiryDate: $0.expiryDate)
                                    })

                                shopping.completeShoppingSession()
                                dismiss()

                                let api = KeepFreshAPI()
                                if let inventoryItems = try? await api.createShoppingSession(request) {
                                    inventory.items.append(contentsOf: inventoryItems)
                                }
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.green500)
                    }
                }
                .alert(
                    "Cancel shop?",
                    isPresented: $presentEndShopAlert)
                {
                    Button("Cancel shop", role: .destructive) {
                        shopping.endShopWithoutSaving()
                        dismiss()
                    }
                    Button("Resume", role: .cancel) {
                        presentEndShopAlert.toggle()
                        dismiss()
                    }
                }
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
}
