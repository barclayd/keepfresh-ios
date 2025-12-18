import DesignSystem
import Models
import SwiftUI
import Utils

struct UpNextPanel: View {
    let storageLocation: StorageLocation
    let shoppingItem: ShoppingItem
    var animation: Namespace.ID

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "arrow.forward.square.fill").resizable()
                        .frame(width: 25, height: 25).foregroundColor(.blue800).fontWeight(.bold)

                    formatCategoryPath(pathDisplay: shoppingItem.product?.category.pathDisplay)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue800)
                        .font(.subheadline)

                    Spacer()
                }
            }
            .padding(.horizontal, 5)
            .frame(maxWidth: .infinity)

            ShoppingModeActiveItem(shoppingItem: shoppingItem, animation: animation)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(
                    (Color.blue800).opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: [11, 6])))
    }
}
