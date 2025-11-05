import DesignSystem
import Environment
import Intelligence
import Models
import Router
import SwiftUI
import TodayUI

private enum SortDirection {
    case forward
    case backward

    func toggle() -> SortDirection {
        switch self {
        case .forward: .backward
        case .backward: .forward
        }
    }
}

private enum InventoryItemSortMode {
    case dateAdded(direction: SortDirection)
    case alphabetical(direction: SortDirection)
    case expiryDate(direction: SortDirection)

    func toggleDirection() -> InventoryItemSortMode {
        switch self {
        case let .dateAdded(direction):
            .dateAdded(direction: direction.toggle())
        case let .alphabetical(direction):
            .alphabetical(direction: direction.toggle())
        case let .expiryDate(direction):
            .expiryDate(direction: direction.toggle())
        }
    }

    func updateSortMode() -> InventoryItemSortMode {
        switch self {
        case .dateAdded: .dateAdded(direction: .forward)
        case .alphabetical: .alphabetical(direction: .forward)
        case .expiryDate: .expiryDate(direction: .forward)
        }
    }

    var baseCase: String {
        switch self {
        case .dateAdded: "dateAdded"
        case .alphabetical: "alphabetical"
        case .expiryDate: "expiryDate"
        }
    }

    var title: String {
        switch self {
        case .alphabetical(direction: .forward): "Sorted (A–Z)"
        case .alphabetical(direction: .backward): "Sorted (Z–A)"
        case .dateAdded(direction: .forward): "Recently added"
        case .dateAdded(direction: .backward): "Oldest items"
        case .expiryDate(direction: .forward): "Expiring first"
        case .expiryDate(direction: .backward): "Expiring last"
        }
    }

    func sort(items: [InventoryItem]) -> [InventoryItem] {
        switch self {
        case let .dateAdded(direction):
            items.sorted { lhs, rhs in
                switch direction {
                case .forward: lhs.createdAt > rhs.createdAt
                case .backward: lhs.createdAt < rhs.createdAt
                }
            }
        case let .alphabetical(direction):
            items.sorted { lhs, rhs in
                let comparison = lhs.product.name.localizedCaseInsensitiveCompare(rhs.product.name)

                if comparison == .orderedSame {
                    return lhs.id < rhs.id
                }

                switch direction {
                case .forward: return comparison == .orderedAscending
                case .backward: return comparison == .orderedDescending
                }
            }
        case let .expiryDate(direction):
            items.sorted { lhs, rhs in
                switch direction {
                case .forward: lhs.expiryDate < rhs.expiryDate
                case .backward: lhs.expiryDate > rhs.expiryDate
                }
            }
        }
    }
}

private struct SortButton: View {
    @Binding var sortMode: InventoryItemSortMode
    let type: InventoryItemSortMode
    let icon: String

    @State private var rotationAngle: Double = 0

    var isActive: Bool {
        type.baseCase == sortMode.baseCase
    }

    public var body: some View {
        Button(action: {
            withAnimation {
                sortMode = isActive ? sortMode.toggleDirection() : type.updateSortMode()
                rotationAngle += 180
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white400)
                .frame(width: 32, height: 32)
                .background(Circle().fill(isActive ? .blue700 : .gray700))
                .rotationEffect(.degrees(rotationAngle))
        }
        .buttonStyle(.plain)
    }
}

public struct StorageLocationView: View {
    @Environment(Router.self) var router
    @Environment(Inventory.self) var inventory

    @State private var sortMode: InventoryItemSortMode = .expiryDate(direction: .forward)

    @State private var usageGenerator = UsageGenerator()

    private var sortedItems: [InventoryItem] {
        sortMode.sort(items: inventory.itemsByStorageLocation[storageLocation] ?? [])
    }

    public var storageLocation: StorageLocation

    public init(storageLocation: StorageLocation) {
        self.storageLocation = storageLocation
    }

    var locationDetails: InventoryLocationDetails? {
        inventory.detailsByStorageLocation[storageLocation]
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                Image(systemName: storageLocation.icon).font(.system(size: 78))
                    .foregroundColor(storageLocation == .pantry ? .blue700 : .white200)

                Text(storageLocation.rawValue).font(.largeTitle).lineSpacing(0)
                    .foregroundStyle(storageLocation == .pantry ? .blue700 : .white200)
                    .fontWeight(.bold)

                if sortedItems.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Let's fill your \(storageLocation.rawValue.lowercased())").font(.headline).foregroundStyle(
                            storageLocation == .freezer ? .white200 : .blue700
                        ).fontWeight(.bold)
                        Text("Tap above to search for or scan a grocery item from your favourite supermarkets")
                            .font(.subheadline).foregroundStyle(
                                storageLocation == .freezer ? .white200 : .blue700).multilineTextAlignment(.center).padding(
                                .horizontal,
                                20)
                    }
                    Spacer()
                } else {
                    if let locationDetails {
                        if usageGenerator.isAvailable {
                            VStack {
                                Text("\(locationDetails.averageConsumptionPredictionPercentage)%").font(.title).foregroundStyle(
                                    .yellow500
                                ).fontWeight(.bold).lineSpacing(0)

                                HStack(spacing: 0) {
                                    Text("Predicted usage").font(.subheadline)
                                        .foregroundStyle(storageLocation == .pantry ? .blue700 : .white200)
                                        .fontWeight(.light)
                                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(
                                        .yellow500
                                    )
                                    .offset(x: -2, y: -10)
                                }.offset(y: -5)
                            }
                        }

                        Grid(horizontalSpacing: 15, verticalSpacing: 10) {
                            GridRow {
                                VStack(spacing: 0) {
                                    Text(locationDetails.expiringSoonCount.formatted())
                                        .foregroundStyle(.green600)
                                        .fontWeight(.bold).font(.headline)
                                    Text("Expiring soon").foregroundStyle(.green600).fontWeight(.light).font(
                                        .subheadline
                                    ).lineLimit(1)
                                }
                                Image(systemName: "hourglass")
                                    .font(.system(size: 28)).fontWeight(.bold)
                                    .foregroundStyle(.blue700)
                                Image(systemName: "clock.badge.exclamationmark")
                                    .font(.system(size: 28)).fontWeight(.bold)
                                    .foregroundStyle(.blue700)
                                VStack(spacing: 0) {
                                    Text(locationDetails.expiringTodayCount.formatted()).fontWeight(.bold)
                                        .font(.headline).foregroundStyle(.blue700)
                                    Text("Expire\(locationDetails.expiringTodayCount == 1 ? "s" : "") today")
                                        .fontWeight(.light).font(.subheadline).foregroundStyle(.blue700)
                                }
                            }
                            GridRow {
                                VStack(spacing: 0) {
                                    Text(locationDetails.recentlyAddedItemsCount.formatted())
                                        .foregroundStyle(.blue700).fontWeight(.bold).font(.headline)
                                    Text("Recently added").foregroundStyle(.blue700).fontWeight(.light).font(
                                        .subheadline
                                    ).lineLimit(1)
                                }
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 28)).fontWeight(.bold)
                                    .foregroundStyle(.blue700)
                                Image(systemName: "list.number")
                                    .font(.system(size: 28)).fontWeight(.bold)
                                    .foregroundStyle(.blue700)
                                VStack(spacing: 0) {
                                    Text(locationDetails.itemsCount.formatted()).fontWeight(.bold)
                                        .font(.headline)
                                        .foregroundStyle(.blue700)
                                    Text("Total item\(locationDetails.itemsCount > 1 ? "s" : "")").fontWeight(
                                        .light
                                    ).font(.subheadline).foregroundStyle(.blue700)
                                }
                            }
                        }.padding(.horizontal, 15).padding(.vertical, 5).frame(
                            maxWidth: .infinity,
                            alignment: .center)
                            .glassEffect(.regular.tint(.blue150), in: .rect(cornerRadius: 20))
                            .cornerRadius(20)

                        HStack {
                            Text(sortMode.title).font(.title3).foregroundStyle(storageLocation == .freezer ? .white200 : .blue700)
                                .fontWeight(.bold)
                            Spacer()
                            HStack(spacing: 8) {
                                SortButton(
                                    sortMode: $sortMode,
                                    type: .dateAdded(direction: .forward),
                                    icon: "clock")
                                SortButton(
                                    sortMode: $sortMode,
                                    type: .alphabetical(direction: .forward),
                                    icon: "arrow.up.arrow.down")
                                SortButton(
                                    sortMode: $sortMode,
                                    type: .expiryDate(direction: .forward),
                                    icon: "hourglass")
                            }
                        }.padding(.vertical, 5)

                        ForEach(sortedItems) { inventoryItem in
                            InventoryItemView(inventoryItem: inventoryItem)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
        .background {
            LinearGradient(stops: storageLocation.viewGradientStops, startPoint: .top, endPoint: .bottom).ignoresSafeArea(.all)
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    router.selectedTab = .search
                }) {
                    Image(systemName: "plus.app").resizable()
                        .frame(width: 24, height: 24).foregroundColor(storageLocation.foregroundColor).fontWeight(.bold)
                }
                Button(action: {
                    router.presentedSheet = .barcodeScan
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24).foregroundColor(storageLocation.foregroundColor).fontWeight(.bold)
                }
            }
        }
    }
}
