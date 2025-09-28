import DesignSystem
import Environment
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

public struct InventoryStoreView: View {
    @Environment(Router.self) var router
    @Environment(Inventory.self) var inventory

    @State private var sortMode: InventoryItemSortMode = .alphabetical(direction: .forward)

    private var sortedItems: [InventoryItem] {
        sortMode.sort(items: inventory.itemsByLocation[inventoryStore] ?? [])
    }

    public var inventoryStore: InventoryStore

    public init(inventoryStore: InventoryStore) {
        self.inventoryStore = inventoryStore
    }

    var locationDetails: InventoryLocationDetails? {
        inventory.detailsByLocation[inventoryStore]
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        LinearGradient(stops: inventoryStore.viewGradientStops, startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea(edges: .top)
                            .offset(y: -geometry.safeAreaInsets.top)
                            .frame(height: geometry.size.height)
                            .frame(maxHeight: .infinity, alignment: .top)

                        VStack(spacing: 15) {
                            Image(systemName: inventoryStore.icon).font(.system(size: 78)).foregroundColor(
                                inventoryStore == .freezer ? .white200 : .blue700
                            )

                            Text(inventoryStore.rawValue).font(.largeTitle).lineSpacing(0).foregroundStyle(
                                .blue700
                            ).fontWeight(.bold)

                            if let locationDetails {
                                VStack {
                                    Text("\(locationDetails.expiryPercentage)%").font(.title).foregroundStyle(
                                        .yellow500
                                    ).fontWeight(.bold).lineSpacing(0)
                                    HStack(spacing: 0) {
                                        Text("Predicted waste score").font(.subheadline).foregroundStyle(.black800)
                                            .fontWeight(.light)
                                        Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(
                                            .yellow500
                                        )
                                        .offset(x: -2, y: -10)
                                    }.offset(y: -5)
                                }

                                Grid(horizontalSpacing: 15, verticalSpacing: 10) {
                                    GridRow {
                                        VStack(spacing: 0) {
                                            Text(locationDetails.expiringSoonCount.formatted()).foregroundStyle(.green600)
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
                                            Text(locationDetails.expiringTodayCount.formatted()).fontWeight(.bold).font(
                                                .headline
                                            ).foregroundStyle(.blue700)
                                            Text("Expire\(locationDetails.expiringTodayCount == 1 ? "s" : "") today")
                                                .fontWeight(.light).font(.subheadline).foregroundStyle(
                                                    .blue700)
                                        }
                                    }
                                    GridRow {
                                        VStack(spacing: 0) {
                                            Text(locationDetails.recentlyAddedItemsCount.formatted()).foregroundStyle(
                                                .blue700
                                            ).fontWeight(.bold).font(.headline)
                                            Text("Recently added").foregroundStyle(.blue700).fontWeight(.light).font(
                                                .subheadline
                                            ).lineLimit(1)
                                        }
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 28)).fontWeight(.bold)
                                            .foregroundStyle(.blue700)
                                        Image(systemName: "list.number")
                                            .font(.system(size: 28)).fontWeight(.bold)
                                            .foregroundStyle(.blue700)
                                        VStack(spacing: 0) {
                                            Text(locationDetails.itemsCount.formatted()).fontWeight(.bold).font(.headline)
                                                .foregroundStyle(.blue700)
                                            Text("Total item\(locationDetails.itemsCount > 1 ? "s" : "")").fontWeight(
                                                .light
                                            ).font(.subheadline).foregroundStyle(
                                                .blue700)
                                        }
                                    }
                                }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center).background(.blue150).cornerRadius(20)

                                HStack {
                                    Text("Recently added").font(.title).foregroundStyle(.blue700).fontWeight(.bold)
                                    Spacer()
                                    HStack(spacing: 8) {
                                        SortButton(sortMode: $sortMode, type: .dateAdded(direction: .forward), icon: "clock")
                                        SortButton(sortMode: $sortMode, type: .alphabetical(direction: .forward),
                                                   icon: "arrow.up.arrow.down")
                                        SortButton(sortMode: $sortMode, type: .expiryDate(direction: .forward), icon: "hourglass")
                                    }
                                }.padding(.vertical, 5)

                                ForEach(sortedItems) { inventoryItem in
                                    InventoryItemView(
                                        inventoryItem: inventoryItem
                                    )
                                }
                            }

                            Spacer()
                        }.padding(.bottom, 100)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                    }
                }.background(.white200)
            }
            .frame(maxHeight: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus.app")
                        .font(.system(size: 18))
                        .foregroundColor(.blue700).fontWeight(.bold)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 18))
                        .foregroundColor(.blue700).fontWeight(.bold)
                }
            }
        }
    }
}
