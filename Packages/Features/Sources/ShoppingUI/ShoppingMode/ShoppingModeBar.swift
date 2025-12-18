import DesignSystem
import Environment
import SwiftUI

public struct ShoppingModeBar: View {
    @Environment(Shopping.self) var shopping

    public init() {}

    var badgeCount: Int {
        shopping.shoppingMode == .initial ? shopping.items.count : shopping.pendingExpiryDates.count
    }

    public var body: some View {
        HStack {
            Label("Add item to shopping list", systemImage: shopping.shoppingMode == .initial ? "list.number" : "basket.fill")
                .font(.title3)
                .bold()
                .labelStyle(.iconOnly)
                .padding(.leading)
                .foregroundStyle(.blue700)
                .conditional(if: badgeCount > 0) { view in
                    view.padding(.trailing, 8)
                        .overlay(alignment: .topTrailing) {
                            Text("\(badgeCount)")
                                .font(.caption2)
                                .foregroundStyle(.white100)
                                .padding(4)
                                .background(.blue700, in: Circle())
                                .offset(x: shopping.shoppingMode == .active ? 2 : 4, y: shopping.shoppingMode == .active ? -10 : -12)
                        }
                        .contentTransition(.numericText())
                        .animation(.default, value: badgeCount)
                }

            VStack(alignment: .leading) {
                Text("Start shop").font(.callout)
                Text("Last shop: 19th December").font(.caption)
            }.foregroundStyle(.blue700)

            Spacer()

            if shopping.shoppingMode == .active {
                Button(action: {}) {
                    Label("Add item to shopping list", systemImage: "camera.viewfinder")
                        .font(.title3)
                        .bold()
                        .labelStyle(.iconOnly)
                        .tint(.blue700)
                        .contentTransition(.symbolEffect(.replace))
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }

            Button(action: {
                if shopping.shoppingMode == .active {
                    shopping.resetShoppingModeItems()
                }
                shopping.shoppingMode = shopping.shoppingMode == .initial ? .active : .initial
            }) {
                Label("Add item to shopping list", systemImage: shopping.shoppingMode == .initial ? "play.fill" : "stop.circle")
                    .font(.title3)
                    .bold()
                    .labelStyle(.iconOnly)
                    .symbolRenderingMode(shopping.shoppingMode == .active ? .palette : .monochrome)
                    .foregroundStyle(
                        shopping.shoppingMode == .initial ? .green500 : .red500,
                        .blue700)
                    .symbolEffect(.breathe, options: .repeating, isActive: shopping.shoppingMode == .active)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(.trailing)
            }
        }
    }
}
