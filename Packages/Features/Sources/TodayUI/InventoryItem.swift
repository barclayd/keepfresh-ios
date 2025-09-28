import Models
import SwiftUI

struct StatsView: View {
    let inventoryItem: InventoryItem

    var body: some View {
        HStack {
            HStack(spacing: 2) {
                if inventoryItem.createdAt.timeSince.amount > 0 {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundStyle(.green600)
                    Text(inventoryItem.createdAt.timeSince.abbreviated)
                        .foregroundStyle(.green600)
                }
            }

            Image(systemName: inventoryItem.storageLocation.iconFilled)
                .font(.system(size: 18))
                .foregroundStyle(.green600)

            HStack(spacing: 2) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18)).foregroundStyle(.yellow500)
                Text("17%").foregroundStyle(.green600)
            }

            Spacer()

            HStack(spacing: 3) {
                Image(systemName: "hourglass")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                Text(inventoryItem.expiryDate.timeUntil.formatted)
                    .foregroundStyle(.green600)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 0,
                                   bottomLeadingRadius: 20,
                                   bottomTrailingRadius: 20,
                                   topTrailingRadius: 0,
                                   style: .continuous)
        )
        .foregroundStyle(.green300)
    }
}

public struct InventoryItemView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State var showInventoryItemSheet: Bool = false

    var inventoryItem: InventoryItem

    public init(inventoryItem: InventoryItem) {
        self.inventoryItem = inventoryItem
    }

    private func getSheetFraction(height: CGFloat) -> CGFloat {
        if dynamicTypeSize >= .xxLarge {
            return 0.8
        }

        print("Height: \(height)")

        switch height {
        case ..<668:
            return 1 // iPhone SE
        case ..<845:
            return 0.9 // iPhone 13
        case ..<957:
            return 0.725 // iPhone 16 Pro Max
        default:
            return 0.5
        }
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                AsyncImage(url: URL(string: inventoryItem.product.categories.imageUrl ?? "https://keep-fresh-images.s3.eu-west-2.amazonaws.com/chicken-leg.png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                VStack(spacing: 2) {
                    HStack {
                        Text(inventoryItem.product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue800)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.green600)
                    }

                    HStack {
                        Text(inventoryItem.product.categories.name)
                            .foregroundStyle(.gray600)
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.gray600)
                        Text(inventoryItem.product.brand.name)
                            .foregroundStyle(inventoryItem.product.brand.color)
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.gray600)
                        Text("\(String(format: "%.0f", inventoryItem.product.amount))\(inventoryItem.product.unit)")
                            .foregroundStyle(.gray600)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(.white)
            .cornerRadius(20)

            StatsView(inventoryItem: inventoryItem)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .onTapGesture {
            // need to add haptics
            showInventoryItemSheet.toggle()
        }
        .sheet(isPresented: $showInventoryItemSheet) {
            InventoryItemSheetView(inventoryItem: inventoryItem)
                .presentationDetents([.fraction(getSheetFraction(height: UIScreen.main.bounds.size.height))]
                )
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
        }
    }
}
