import Models
import SwiftUI

struct StatsView: View {
    let consumableItem: ConsumableItem

    var body: some View {
        HStack {
            HStack(spacing: 2) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundStyle(.gray400)
                Text("2w")
                    .foregroundStyle(.gray400)
            }

            Image(systemName: "refrigerator.fill")
                .font(.system(size: 18))
                .foregroundStyle(.gray400)

            HStack(spacing: 2) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                Text("17%")

            }.foregroundStyle(.yellow500)

            Spacer()

            HStack(spacing: 3) {
                Image(systemName: "hourglass")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                Text("3 days")
                    .foregroundStyle(.green600)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
        .foregroundStyle(.green300)
    }
}

public struct ConsumableItemView: View {
    @Binding var selectedConsumableItem: ConsumableItem?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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

    let consumableItem: ConsumableItem

    public init(selectedConsumableItem: Binding<ConsumableItem?>, consumableItem: ConsumableItem) {
        _selectedConsumableItem = selectedConsumableItem
        self.consumableItem = consumableItem
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                AsyncImage(url: URL(string: consumableItem.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                VStack(spacing: 2) {
                    HStack {
                        Text(consumableItem.name)
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
                        Text(consumableItem.category)
                            .foregroundStyle(.gray600)
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.gray600)
                        Text(consumableItem.brand)
                            .foregroundStyle(.brandSainsburys)
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.gray600)
                        Text("\(String(format: "%.0f", consumableItem.amount))\(consumableItem.unit)")
                            .foregroundStyle(.gray600)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(.white)
            .cornerRadius(20)

            StatsView(consumableItem: consumableItem)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .onTapGesture {
            // need to add haptics
            selectedConsumableItem = consumableItem
        }
        .sheet(item: $selectedConsumableItem) { _ in
            ConsumableItemSheetView(consumableItem: $selectedConsumableItem)
                .presentationDetents([.fraction(getSheetFraction(height: UIScreen.main.bounds.size.height))]
                )
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
        }
    }
}
