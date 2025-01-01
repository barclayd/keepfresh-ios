import DesignSystem
import Models
import SwiftUI

struct InventoryStat: Identifiable {
    var icon: String
    var label: String

    var id: String { icon }
}

struct StatsView: View {
    let inventoryStoreDetails: InventoryStoreDetails

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
                Text(inventoryStoreDetails.name).foregroundStyle(inventoryStoreDetails.type.titleForegorundColor).font(.title).fontWeight(.bold)
                Spacer()
            }
            HStack {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(stats) { stat in
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Image(systemName: stat.icon)
                                .font(.system(size: 18)).foregroundStyle(stat.icon == "hourglass" ? inventoryStoreDetails.expiryStatusPercentageColor : inventoryStoreDetails.type.foregorundColor)

                            Text(stat.label).font(.body).foregroundStyle(stat.icon == "hourglass" ? inventoryStoreDetails.expiryStatusPercentageColor : inventoryStoreDetails.type.foregorundColor)
                        }
                    }
                }

                Spacer()

                HStack(spacing: 0) {
                    ForEach(Array(recentItemImages.reversed().enumerated()), id: \.offset) { index, image in
                        Image(systemName: image)
                            .font(.system(size: 18))
                            .foregroundStyle(inventoryStoreDetails.type.foregorundColor)
                            .opacity(Double(recentItemImages.count - index) / Double(recentItemImages.count))
                            .offset(x: CGFloat(recentItemImages.count - index > 0 ? (recentItemImages.count - index - 1) * 10 : 0))
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
                        Gradient.Stop(color: inventoryStoreDetails.type.gradientStops.start, location: 0),
                        Gradient.Stop(color: inventoryStoreDetails.type.gradientStops.end, location: 1),
                    ], startPoint: .leading, endPoint: .trailing
                ))
        )
    }
}

private struct InventoryStore: View {
    let inventoryStoreDetails: InventoryStoreDetails

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Image(systemName: inventoryStoreDetails.type.icon)
                    .font(.system(size: 36))

                Spacer()

                VStack {
                    Circle()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(inventoryStoreDetails.expiryStatusPercentageColor)
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .padding(.top, 5)
            .padding(.horizontal, 10)
            .background(Color.white)
            .cornerRadius(20)

            StatsView(inventoryStoreDetails: inventoryStoreDetails)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

public struct KitchenView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                InventoryStore(inventoryStoreDetails: InventoryStoreDetails(
                    id: 1, name: "Pantry", type: .pantry, expiryStatusPercentage: 12, lastUpdated: Date(), itemsCount: 12,
                    openItemsCount: 3, itemsExpiringSoonCount: 4,
                    recentItemImages: ["popcorn.fill", "birthday.cake.fill", "carrot.fill"]
                ))
                InventoryStore(inventoryStoreDetails: InventoryStoreDetails(
                    id: 1, name: "Fridge", type: .fridge, expiryStatusPercentage: 43, lastUpdated: Date(), itemsCount: 12,
                    openItemsCount: 3, itemsExpiringSoonCount: 4,
                    recentItemImages: ["popcorn.fill", "birthday.cake.fill", "carrot.fill"]
                ))
                InventoryStore(inventoryStoreDetails: InventoryStoreDetails(
                    id: 1, name: "Freezer", type: .freezer, expiryStatusPercentage: 80, lastUpdated: Date(), itemsCount: 12,
                    openItemsCount: 3, itemsExpiringSoonCount: 4,
                    recentItemImages: ["popcorn.fill", "birthday.cake.fill", "carrot.fill"]
                ))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        }.padding(.vertical, 10).background(.white200)
    }
}
