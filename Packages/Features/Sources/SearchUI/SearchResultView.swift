import DesignSystem
import Extensions
import Models
import Router
import SharedUI
import SwiftUI

public struct SearchResultView: View {
    var products: [ProductSearchItemResponse]
    var isLoading: Bool = false

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(products) { product in
                    NavigationLink(value: RouterDestination.addProduct(product: product)) {
                        SearchResultCard(product: product)
                            .toolbarVisibility(.hidden, for: .tabBar)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 16)
            .redactedShimmer(when: isLoading)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

public struct SearchResultCard: View {
    var product: ProductSearchItemResponse

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                GenmojiView(name: product.icon, fontSize: 28, tint: .white200)

                Text(product.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white200)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.blue700))
            }
            .padding(.vertical, 7.5)
            .padding(.horizontal, 10)
            .background(product.category.recommendedStorageLocation.tileColor)
            .cornerRadius(20)

            VStack {
                HStack {
                    Text(product.category.name)
                        .font(.subheadline).foregroundStyle(.gray500)
                    Spacer()
                }
                HStack {
                    Text(product.brand.name)
                        .font(.subheadline)
                        .foregroundStyle(product.brand.color)

                    if let amount = product.amount, let unit = product.unit {
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.blue700)

                        Text("\(String(format: "%.0f", amount))\(unit)")
                            .foregroundStyle(.gray500)
                            .font(.subheadline)
                    }

                    Spacer()
                    Image(systemName: "clock")
                        .font(.callout)
                        .foregroundStyle(.blue700)
                }
            }.padding(.horizontal, 5).padding(10).padding(.bottom, 5)
                .background(UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 0,
                    style: .continuous).fill(.white100))
        }
        .background(product.category.recommendedStorageLocation.tileColor)
        .cornerRadius(20)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}
