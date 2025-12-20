import Environment
import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct ReadOnlyOtherShoppingItemView: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    @State private var shoppingItem: ShoppingItem

    public init(shoppingItem: ShoppingItem) {
        self.shoppingItem = shoppingItem
    }

    public var body: some View {
        HStack(spacing: 0) {
            HStack {
                HStack {
                    Text(shoppingItem.title ?? "")
                        .font(.headline)
                        .foregroundStyle(.blue800)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)

                    Spacer()
                }
                .contentShape(Rectangle())

                Button(action: {
                    withAnimation {
                        shopping.deleteItem(id: shoppingItem.id)
                    }
                }) {
                    Image(systemName: "xmark").resizable().frame(width: 12, height: 12).foregroundStyle(.blue700).fontWeight(.bold)
                        .padding(.leading, 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 9)
        .background(.white100)
        .background(.white100)
        .cornerRadius(22)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
    }
}
