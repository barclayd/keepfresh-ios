import DesignSystem
import Environment
import Models
import Router
import SwiftUI
import TodayUI

struct InventoryStat: Identifiable {
    var icon: String
    var customIcon: String?
    var amount: Int?
    
    var id: String { icon }
}

struct StatsView: View {
    let storageLocation: StorageLocation
    let locationDetails: InventoryLocationDetails?
    
    var stats: [InventoryStat] {
        [
            .init(icon: "list.number", amount: locationDetails?.itemsCount),
            .init(icon: "envelope.open.fill", customIcon: "tin.open", amount: locationDetails?.openItemsCount),
            .init(icon: "hourglass", amount: locationDetails?.expiringSoonCount),
        ]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            HStack {
                if locationDetails != nil {
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(stats) { stat in
                            if let amount = stat.amount {
                                HStack(spacing: 4) {
                                    if let customIcon = stat.customIcon {
                                        Image(customIcon).renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 22, height: 22)
                                            .foregroundStyle(storageLocation.foregroundColor)
                                    } else {
                                        Image(systemName: stat.icon).font(.system(size: 18))
                                            .foregroundStyle(
                                                storageLocation.foregroundColor)
                                    }
                                    
                                    Text("\(amount)").font(.body)
                                        .foregroundStyle(storageLocation.foregroundColor)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                } else {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "list.number")
                                .font(.system(size: 18))
                            Text("0").font(.body)
                        }
                        Spacer()
                    }.foregroundStyle(storageLocation.foregroundColor)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 20,
            bottomTrailingRadius: 20,
            topTrailingRadius: 0,
            style: .continuous).fill(LinearGradient(stops: [
            Gradient.Stop(
                color: storageLocation.previewGradientStops.start,
                location: 0),
            Gradient.Stop(
                color: storageLocation.previewGradientStops.end,
                location: 1),
        ], startPoint: .leading, endPoint: .trailing)))
    }
}

private struct StorageLocationTileView: View {
    @Environment(Inventory.self) var inventory
    
    let storageLocation: StorageLocation
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Image(systemName: storageLocation.icon)
                    .font(.system(size: 36)).foregroundStyle(.blue800)
                
                Text(storageLocation.rawValue).foregroundStyle(.blue800).font(.title).fontWeight(.bold)
                
                Spacer()
                
                if let locationDetails = inventory.detailsByStorageLocation[storageLocation] {
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
            .background(.white100)
            .cornerRadius(20)
            
            StatsView(storageLocation: storageLocation, locationDetails: inventory.detailsByStorageLocation[storageLocation])
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white100)
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
                ForEach(StorageLocation.allCases) { storageLocation in
                    NavigationLink(value: RouterDestination.storageLocationView(storageLocation: storageLocation)) {
                        StorageLocationTileView(storageLocation: storageLocation)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .containerBackground(.white200, for: .navigation)
    }
}
