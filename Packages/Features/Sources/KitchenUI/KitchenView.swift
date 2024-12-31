import DesignSystem
import Models
import SwiftUI

struct InventoryStat: Identifiable {
    var icon: String
    var label: String

    var id: String { icon }
}

struct StatsView: View {
    let stats: [InventoryStat] = [
        .init(icon: "calendar", label: "2w"),
        .init(icon: "list.number", label: "18"),
        .init(icon: "envelope.open.fill", label: "12"),
        .init(icon: "hourglass", label: "3"),
    ]

    let recentItemImages = ["popcorn.fill", "birthday.cake.fill", "carrot.fill"]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Pantry").foregroundStyle(.blue800).font(.title).fontWeight(.bold)
                Spacer()
            }
            HStack {
                HStack(spacing: 12) {
                    ForEach(stats) { stat in
                        HStack(spacing: 6) {
                            Image(systemName: stat.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(.gray700)
                            Text(stat.label).font(.body).foregroundStyle(.gray700)
                        }
                    }
                }.fixedSize(horizontal: true, vertical: false)

                Spacer()

                HStack {
                    Spacer()
                    HStack(spacing: 0) {
                        ForEach(Array(recentItemImages.reversed().enumerated()), id: \.offset) { index, image in
                            Image(systemName: image)
                                .font(.system(size: 18))
                                              .foregroundStyle(.gray700)
                                .opacity(Double(recentItemImages.count - index) / Double(recentItemImages.count))
                                .offset(x: CGFloat(recentItemImages.count - index > 0 ? (recentItemImages.count - index - 1) * 10 : 0))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0,
                style: .continuous
            ).fill(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .brown100, location: 0),
                        Gradient.Stop(color: .brown300, location: 1),
                    ], startPoint: .leading, endPoint: .trailing
                ))
        )
    }
}

public struct KitchenView: View {
    let inventoryStoreDetails = InventoryStoreDetails(
        id: 1, type: .pantry, expiryStatusPercentage: 3.4, lastUpdated: Date(), itemsCount: 12,
        openItemsCount: 3, itemsExpiringSoonCount: 4,
        recentItemImages: ["popcorn.fill", "birthday.cake.fill", "carrot.fill"]
    )

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: inventoryStoreDetails.type.icon)
                        .font(.system(size: 36))

                    Spacer()

                    VStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.green600)
                        Spacer()
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(20)

                StatsView()
            }
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
            .background(Color.white)
            .cornerRadius(20)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        }.padding(.vertical, 10).background(.white200)
    }
}
