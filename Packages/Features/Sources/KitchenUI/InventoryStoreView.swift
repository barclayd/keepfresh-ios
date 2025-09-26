import DesignSystem
import Models
import Router
import SwiftUI
import Environment
import TodayUI

private enum SortDirection {
    case forward
    case backward
    
    func toggle() -> SortDirection {
        switch self {
        case .forward: return .backward
        case .backward: return .forward
        }
    }
}

private enum InventoryItemSortMode {
    case dateAdded(direction: SortDirection)
    case alphabetical(direction: SortDirection)
    case expiryDate(direction: SortDirection)
    
    var isDateAdded: Bool {
        if case .dateAdded = self { return true }
        return false
    }
    
    var isAlphabetical: Bool {
        if case .alphabetical = self { return true }
        return false
    }
    
    var isExpiryDate: Bool {
        if case .expiryDate = self { return true }
        return false
    }
    
    func toggleDirection() -> InventoryItemSortMode {
        switch self {
        case let .dateAdded(direction: direction):
            return .dateAdded(direction: direction.toggle())
        case let .alphabetical(direction: direction):
            return .alphabetical(direction: direction.toggle())
        case let .expiryDate(direction: direction):
            return .expiryDate(direction: direction.toggle())
        }
    }
    
    func updateSortMode() -> InventoryItemSortMode {
        switch self {
        case .dateAdded: return .dateAdded(direction: .forward)
        case .alphabetical: return .alphabetical(direction: .forward)
        case .expiryDate: return .expiryDate(direction: .forward)
        }
    }
    
    var baseCase: String {
        switch self {
        case .dateAdded: return "dateAdded"
        case .alphabetical: return "alphabetical"
        case .expiryDate: return "expiryDate"
        }
    }
}

private struct SortButton: View {
    @Binding var sortMode: InventoryItemSortMode
    let type: InventoryItemSortMode
    let icon: String
    
    var isActive: Bool {
        type.baseCase == sortMode.baseCase
    }
    
    public var body: some View {
        Button(action: {
            if isActive {
                let toggledDirection = sortMode.toggleDirection()
                sortMode = toggledDirection
            } else {
                sortMode = type.updateSortMode()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white400)
                .frame(width: 32, height: 32)
                .background(Circle().fill(isActive ? .blue700 : .gray700))
        }
    }
}

struct StoreColors: Hashable {
    let defaultColor: Color
    let onScrollColor: Color
}

public struct InventoryStoreView: View {
    @Environment(Router.self) var router
    @Environment(Inventory.self) var inventory
        
    @State private var selectedInventoryItem: InventoryItem? = nil
    @State private var sortMode: InventoryItemSortMode = .alphabetical(direction: .forward)
    @State private var didScrollPastOmbreColor = false
    
    public let inventoryStore: InventoryStoreDetails
    
    public init(inventoryStore: InventoryStoreDetails) {
        self.inventoryStore = inventoryStore
    }
    
    let inventoryStoreToScrollOffset: [InventoryStore: CGFloat] = [.pantry: -50, .fridge: 70, .freezer: 100]
    
    let inventoryStoreToToolbarColor: [InventoryStore: StoreColors] = [
        .pantry: StoreColors(
            defaultColor: .blue700,
            onScrollColor: .blue700
        ),
        .fridge: StoreColors(
            defaultColor: .white200,
            onScrollColor: .blue700
        ),
        .freezer: StoreColors(
            defaultColor: .white200,
            onScrollColor: .blue700
        ),
    ]
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        LinearGradient(
                            stops: inventoryStore.type.viewGradientStops, startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                        .offset(y: -geometry.safeAreaInsets.top)
                        .frame(height: geometry.size.height)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        VStack(spacing: 15) {
                            Image(systemName: inventoryStore.type.icon).font(.system(size: 78)).foregroundColor(
                                .blue700)
                            Text(inventoryStore.name).font(.largeTitle).lineSpacing(0).foregroundStyle(
                                .blue700
                            ).fontWeight(.bold)
                            
                            VStack {
                                Text("3%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold).lineSpacing(0)
                                HStack(spacing: 0) {
                                    Text("Predicted waste score").font(.subheadline).foregroundStyle(.black800)
                                        .fontWeight(.light)
                                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                                        .offset(x: -2, y: -10)
                                }.offset(y: -5)
                            }
                            
                            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                                GridRow {
                                    VStack(spacing: 0) {
                                        Text("3").foregroundStyle(.green600).fontWeight(.bold).font(.headline)
                                        Text("Expriing soon").foregroundStyle(.green600).fontWeight(.light).font(
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
                                        Text("1").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("Expires today").fontWeight(.light).font(.subheadline).foregroundStyle(
                                            .blue700)
                                    }
                                }
                                GridRow {
                                    VStack(spacing: 0) {
                                        Text("32").foregroundStyle(.blue700).fontWeight(.bold).font(.headline)
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
                                        Text("34").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("Total items").fontWeight(.light).font(.subheadline).foregroundStyle(
                                            .blue700)
                                    }
                                }
                            }.padding(.horizontal, 15).padding(.vertical, 5).frame(
                                maxWidth: .infinity, alignment: .center
                            ).background(.blue150).cornerRadius(20)
                            
                            HStack {
                                Text("Recently added").font(.title).foregroundStyle(.blue700).fontWeight(.bold)
                                Spacer()
                                HStack(spacing: 8) {
                                    SortButton(
                                        sortMode: $sortMode, type: .dateAdded(direction: .forward), icon: "clock"
                                    )
                                    SortButton(
                                        sortMode: $sortMode, type: .alphabetical(direction: .forward),
                                        icon: "arrow.up.arrow.down"
                                    )
                                    SortButton(
                                        sortMode: $sortMode, type: .expiryDate(direction: .forward), icon: "hourglass"
                                    )
                                }
                            }.padding(.vertical, 5)
                            
                            ForEach(inventory.itemsByStore[inventoryStore.type]!) { inventoryItem in
                                InventoryItemView(
                                    inventoryItem: inventoryItem
                                )
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 100)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                    }
                }.background(.white200)
            }
            .frame(maxHeight: geometry.size.height)
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y
            }, action: { _, newValue in
                withAnimation {
                    if newValue > inventoryStoreToScrollOffset[inventoryStore.type, default: 0] {
                        router.customTintColor = inventoryStoreToToolbarColor[inventoryStore.type]?.onScrollColor
                        didScrollPastOmbreColor = true
                    } else {
                        router.customTintColor = inventoryStoreToToolbarColor[inventoryStore.type]?.defaultColor
                        didScrollPastOmbreColor = false
                    }
                }
            })
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbarRole(.editor)
        .toolbarBackground(didScrollPastOmbreColor ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus.app")
                        .font(.system(size: 18))
                        .foregroundColor(didScrollPastOmbreColor ? inventoryStoreToToolbarColor[inventoryStore.type]?.onScrollColor : inventoryStoreToToolbarColor[inventoryStore.type]?.defaultColor).fontWeight(.bold)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 18))
                        .foregroundColor(didScrollPastOmbreColor ? inventoryStoreToToolbarColor[inventoryStore.type]?.onScrollColor : inventoryStoreToToolbarColor[inventoryStore.type]?.defaultColor).fontWeight(.bold)
                }
            }
        }
    }
}
