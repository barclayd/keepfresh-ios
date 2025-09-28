import DesignSystem
import Models
import Router
import SwiftUI

public struct SearchResultView: View {
    var products: [ProductSearchItemResponse]

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(products) { product in
                    NavigationLink(
                        value: RouterDestination.addProduct(product: product)
                    ) {
                        SearchResultCard(product: product)
                            .toolbarVisibility(.hidden, for: .tabBar)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 16)
        }
    }
}

public struct SearchResultCard: View {
    var product: ProductSearchItemResponse

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                AsyncImage(url: product.imageURL.flatMap(URL.init)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white200))
                }
                .frame(width: 28, height: 28)
                Text(product.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white200)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.blue700))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(.blue400)
            .cornerRadius(20)

            VStack {
                HStack {
                    Text(product.category.path)
                        .font(.subheadline).foregroundStyle(.gray500)
                    Spacer()
                }
                HStack {
                    Text(product.brand)
                        .font(.subheadline)
                        .foregroundStyle(.brandSainsburys)

                    if product.amount != nil, product.unit != nil {
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.blue700)

                        Text(
                            "\(String(format: "%.0f", product.amount ?? 1))\(product.unit ?? "g")"
                        ).foregroundStyle(.gray500)
                            .font(.subheadline)
                    }

                    Spacer()
                    Image(systemName: "clock")
                        .font(.callout)
                        .foregroundStyle(.blue700)
                }
            }.padding(.horizontal, 5).padding(10).padding(.bottom, 5)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 0,
                                           bottomLeadingRadius: 20,
                                           bottomTrailingRadius: 20,
                                           topTrailingRadius: 0,
                                           style: .continuous).fill(.white)
                )
        }
        .background(.blue400)
        .cornerRadius(20)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}
