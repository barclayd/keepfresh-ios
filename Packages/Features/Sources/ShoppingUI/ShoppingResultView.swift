import DesignSystem
import Extensions
import Models
import Router
import SharedUI
import SwiftUI

public struct SearchShoppingResultView: View {
    var searchProducts: [ProductSearchResultItemResponse]
    var isLoading: Bool = false
    var hasMorePages: Bool = false
    var isLoadingMore: Bool = false
    var onLoadMore: (() -> Void)?

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(searchProducts) { product in
                    SearchShoppingResultCard(searchProduct: product)
                        .toolbarVisibility(.hidden, for: .tabBar)
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            if product.id == searchProducts.last?.id, hasMorePages, !isLoadingMore {
                                onLoadMore?()
                            }
                        }
                }

                if isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 16)
            .redactedShimmer(when: isLoading)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

public struct SearchShoppingResultCard: View {
    @State private var isAddedToList: Bool = false

    var searchProduct: ProductSearchResultItemResponse

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                GenmojiView(name: searchProduct.icon, fontSize: 28, tint: .white200)

                Text(searchProduct.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(searchProduct.category.recommendedStorageLocation == .freezer ? .white200 : .blue700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Spacer()
                Image(systemName: isAddedToList ? "checkmark" : "plus")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white200)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.blue700))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(searchProduct.category.recommendedStorageLocation.tileColor)
            .cornerRadius(20)

            VStack {
                HStack {
                    Text(searchProduct.category.path)
                        .font(.subheadline).foregroundStyle(.gray500)
                    Spacer()
                }
                HStack {
                    Text(searchProduct.brand.name)
                        .font(.subheadline)
                        .foregroundStyle(searchProduct.brand.color)

                    if let amountFormatted = searchProduct.amountUnitFormatted {
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.blue700)

                        Text(amountFormatted)
                            .foregroundStyle(.gray500)
                            .font(.subheadline)
                    }

                    Spacer()
                }
            }.padding(.horizontal, 5).padding(10).padding(.bottom, 5)
                .background(UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 0,
                    style: .continuous).fill(.white100))
        }
        .onTapGesture {
            isAddedToList = true
        }
        .background(searchProduct.category.recommendedStorageLocation.tileColor)
        .cornerRadius(20)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .sensoryFeedback(.selection, trigger: isAddedToList)
    }
}
