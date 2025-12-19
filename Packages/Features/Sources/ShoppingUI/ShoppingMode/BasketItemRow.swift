import DesignSystem
import Environment
import Models
import SharedUI
import SwiftUI

struct BasketItemRow: View {
    @Environment(Shopping.self) var shopping

    let item: ShoppingItem

    private var expiryDate: Date? {
        item.expiryDate
    }

    var body: some View {
        HStack(spacing: 0) {
            if let icon = item.product?.category.icon {
                GenmojiView(
                    name: icon,
                    fontSize: 35,
                    tint: item.storageLocation?.backgroundColor ?? .gray600
                )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title ?? item.product?.name ?? "")
                    .font(.headline)
                    .foregroundStyle(.blue800)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if let product = item.product {
                        if let logoAsset = product.brand.logoAssetName {
                            Image(logoAsset)
                                .resizable()
                                .frame(width: 14, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: product.brand.hasRoundedLogo ? 4 : 0))
                        }

                        Text(product.brand.name)
                            .foregroundStyle(product.brand.color)
                            .font(.caption)

                        if let amountUnit = product.amountUnitFormatted {
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundStyle(.gray600)
                            Text(amountUnit)
                                .foregroundStyle(.gray600)
                                .font(.caption)
                        }
                    }

                    if let expiryDate {
                        Circle()
                            .frame(width: 3, height: 3)
                            .foregroundStyle(.gray600)
                        Text(expiryDate, format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(.gray600)
                            .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 5)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green500)
                .font(.title2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(.white100)
        .cornerRadius(22)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}
