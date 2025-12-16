import DesignSystem
import Environment
import SwiftUI

public struct ShoppingModeBar: View {
    @Environment(Shopping.self) var shopping

    public init() {}

    public var body: some View {
        HStack {
            Label("Add item to shopping list", systemImage: shopping.shoppingMode == .initial ? "list.number" : "basket.fill")
                .font(.title3)
                .bold()
                .labelStyle(.iconOnly)
                .padding(.leading)
                .foregroundStyle(.blue700)

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
                shopping.shoppingMode = shopping.shoppingMode == .initial ? .active : .initial
            }) {
                Label("Add item to shopping list", systemImage: shopping.shoppingMode == .initial ? "play.fill" : "stop.fill")
                    .font(.title3)
                    .bold()
                    .labelStyle(.iconOnly)
                    .tint(shopping.shoppingMode == .initial ? .green500 : .red500)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(.trailing)
            }
        }
    }
}
