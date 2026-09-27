import AppIntents
import Models
import SwiftUI

struct CollectButton: View {
    let item: ShoppingActivityAttributes.Item
    let sessionID: String
    let tint: Color

    var body: some View {
        Button(intent: CollectShoppingItemIntent(sessionID: sessionID, itemID: item.id)) {
            ActivityActionSymbol(symbol: "checkmark", tint: tint)
        }
        .buttonStyle(.plain)
        .disabled(item.id <= 0)
        .opacity(item.id <= 0 ? 0.45 : 1)
        .accessibilityLabel(item.id > 0 ? "Put \(item.title) in basket" : "Saving \(item.title)")
        .accessibilityHint("Shows the next item on your shopping list")
    }
}

struct ReviewBasketButton: View {
    let tint: Color

    var body: some View {
        Link(destination: ShoppingActivityController.basketURL) {
            ActivityActionSymbol(symbol: "arrow.up.right", tint: tint)
        }
        .accessibilityLabel("Review basket")
    }
}

private struct ActivityActionSymbol: View {
    let symbol: String
    let tint: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(ShoppingActivityStyle.background)
            .frame(width: 44, height: 44)
            .background(tint, in: Circle())
            .contentShape(Circle())
    }
}
