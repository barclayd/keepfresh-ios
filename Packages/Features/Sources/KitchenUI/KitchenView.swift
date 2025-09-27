import DesignSystem
import Environment
import Models
import Router
import SwiftUI
import TodayUI

struct InventoryStat: Identifiable {
    var icon: String
    var label: String
    
    var id: String { icon }
}

struct StatsView: View {
    let inventoryStore: InventoryStore
    let locationDetails: InventoryLocationDetails?
    
    var stats: [InventoryStat] {
        return [
            .init(icon: "calendar", label: ""),
            .init(icon: "list.number", label: "18"),
            .init(icon: "envelope.open.fill", label: "12"),
            .init(icon: "hourglass", label: "3"),
        ]
    }
    
    let recentItemImages = ["popcorn.fill", "birthday.cake.fill", "carrot.fill"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(inventoryStore.rawValue).foregroundStyle(inventoryStore.titleForegorundColor).font(.title).fontWeight(.bold)
                Spacer()
            }
            HStack {
                if let locationDetails = locationDetails {
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(stats) { stat in
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Image(systemName: stat.icon)
                                    .font(.system(size: 18)).foregroundStyle(stat.icon == "hourglass" ? locationDetails.expiryStatusPercentageColor : inventoryStore.foregorundColor)
                                
                                Text(stat.label).font(.body).foregroundStyle(stat.icon == "hourglass" ? locationDetails.expiryStatusPercentageColor : inventoryStore.foregorundColor)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(Array(recentItemImages.reversed().enumerated()), id: \.offset) { index, image in
                            Image(systemName: image)
                                .font(.system(size: 18))
                                .foregroundStyle(inventoryStore.foregorundColor)
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
                        Gradient.Stop(color: inventoryStore.previewGradientStops.start, location: 0),
                        Gradient.Stop(color: inventoryStore.previewGradientStops.end, location: 1),
                    ], startPoint: .leading, endPoint: .trailing
                ))
        )
    }
}

private struct InventoryStoreTileView: View {
    @Environment(Inventory.self) var inventory
    
    let inventoryStore: InventoryStore
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Image(systemName: inventoryStore.icon)
                    .font(.system(size: 36))
                
                Spacer()
                
                if let locationDetails = inventory.detailsByLocation[inventoryStore] {
                    VStack {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(locationDetails.expiryStatusPercentageColor)
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.top, 5)
            .padding(.horizontal, 10)
            .background(Color.white)
            .cornerRadius(20)
            
            StatsView(inventoryStore: inventoryStore, locationDetails: inventory.detailsByLocation[inventoryStore])
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}

public struct KitchenView: View {
    public init() {}
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 25) {
                ForEach(InventoryStore.allCases) { inventoryStore in
                    NavigationLink(value: RouterDestination.inventoryStoreView(inventoryStore: inventoryStore)) {
                        InventoryStoreTileView(inventoryStore: inventoryStore)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }.padding(.vertical, 10).background(.white200)
    }
}
