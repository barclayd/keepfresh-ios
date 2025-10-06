import DesignSystem
import Environment
import Extensions
import Models
import Network
import Router
import SwiftUI

public struct TodayView: View {
    public init() {}

    @Environment(Inventory.self) var inventory
    @Environment(Router.self) var router

    public var body: some View {
        if inventory.items.isEmpty {
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Image("arrow.curved.right")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .foregroundStyle(.green500)
                }.padding(.horizontal, 40)

                Text("Bring your fridge to your pocket").font(.headline).foregroundStyle(
                    .blue600
                ).fontWeight(.bold)
                Text("Tap above to search for or scan a grocery item from the UK’s favourite supermarkets").font(.subheadline)
                    .foregroundStyle(
                        .blue800).multilineTextAlignment(.center).padding(.horizontal, 20)

                Spacer()

                Text("Need some inspiraton?").font(.subheadline).foregroundStyle(
                    .blue600
                ).fontWeight(.bold)

                Button(action: {
                    Task {
                        let api = KeepFreshAPI()
                        let product = try await api.getRandomProduct().product

                        print("product", product)

                        router.navigateTo(.addProduct(product: product))
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 18))
                            .frame(width: 20, alignment: .center)
                        Text("Random item")
                            .font(.headline)
                            .frame(width: 175, alignment: .center)
                    }
                    .foregroundStyle(.green600)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.green300))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(.white200)
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(inventory.itemsSortedByExpiryAscending) { inventoryItem in
                        InventoryItemView(inventoryItem: inventoryItem)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .redactedShimmer(when: inventory.state == .loading)
            }
            .background(.white200)
        }
    }
}
