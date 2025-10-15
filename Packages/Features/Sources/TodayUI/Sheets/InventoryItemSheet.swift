import DesignSystem
import Environment
import Models
import Network
import SharedUI
import SwiftUI

struct NextBestAction {
    public let label: String
    public let icon: String
    public let textColor: Color
    public let backgroundColor: Color
    public let action: () -> Void
}

extension InventoryItem {
    func getNextBestAction(
        onOpen: @escaping () -> Void,
        onMove: @escaping (StorageLocation) -> Void) -> NextBestAction?
    {
        switch (status, storageLocation) {
        case (.unopened, _):
            NextBestAction(
                label: "Mark as opened",
                icon: "door.right.hand.open",
                textColor: .blue600,
                backgroundColor: .gray200,
                action: onOpen)
        case (.opened, .freezer):
            NextBestAction(
                label: "Move to Fridge",
                icon: "refrigerator.fill",
                textColor: .white100,
                backgroundColor: .blue600,
                action: { onMove(.fridge) })
        case (.opened, .pantry):
            NextBestAction(
                label: "Move to Fridge",
                icon: "refrigerator.fill",
                textColor: .white100,
                backgroundColor: .blue600,
                action: { onMove(.fridge) })
        case (.opened, .fridge):
            NextBestAction(
                label: "Move to Freezer",
                icon: "snowflake",
                textColor: .white200,
                backgroundColor: .blue700,
                action: { onMove(.freezer) })
        default:
            nil
        }
    }
}

struct InventoryItemSheetStatsGridRows: View {
    @Environment(Inventory.self) var inventory
    
    let pageIndex: Int
    
    var inventoryItem: InventoryItem
    
    var body: some View {
        Group {
            if pageIndex == 0 {
                GridRow(alignment: .center,) {
                    VStack(spacing: 0) {
                        Text("\(inventoryItem.expiryDate.timeUntil.amount)").foregroundStyle(.green600)
                            .fontWeight(.bold).font(.headline)
                        Text(inventoryItem.expiryDate.timeUntil.formattedToExpiry)
                            .foregroundStyle(.green600).fontWeight(.light).font(.subheadline)
                            .lineLimit(1)
                    }
                    Image(systemName: "hourglass")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    Image(systemName: "sparkles")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.yellow400)
                    VStack(spacing: 0) {
                        Text("\(inventoryItem.consumptionPrediction)%").fontWeight(.bold).font(.headline)
                        Text("Predicted use").fontWeight(.light).font(.subheadline)
                    }.foregroundStyle(.blue700)
                }
                
                GridRow(alignment: .center) {
                    Text(inventoryItem.storageLocation.rawValue).fontWeight(.bold).font(.headline)
                    Image(systemName: inventoryItem.storageLocation.icon)
                        .font(.system(size: 28)).fontWeight(.bold)
                    Image(systemName: "circle.bottomrighthalf.pattern.checkered")
                        .font(.system(size: 28)).fontWeight(.bold)
                    Text(inventoryItem.product.brand.name).fontWeight(.bold)
                        .foregroundStyle(inventoryItem.product.brand.color).font(.headline)
                        .lineLimit(1)
                }.foregroundStyle(.blue700)
            } else {
                GridRow {
                    VStack(spacing: 0) {
                        Text("Added").fontWeight(.light).font(.subheadline).lineLimit(1)
                        Text(inventoryItem.createdAt.timeSince.formattedElapsedTime).fontWeight(.bold).font(.headline)
                    }.foregroundStyle(.blue700)
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 32)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    VStack(spacing: 0) {
                        Text("\(inventoryItem.status == .opened ? "Opened" : "Updated")").fontWeight(.light)
                            .font(.subheadline)
                        Text(
                            inventoryItem.openedAt?.timeSince.formattedElapsedTime ?? inventoryItem.updatedAt.timeSince
                                .formattedElapsedTime).fontWeight(.bold).font(.headline)
                    }.foregroundStyle(.blue700)
                }
                
                GridRow {
                    VStack(spacing: 0) {
                        Text("\(inventory.productCountsByLocation[inventoryItem.product.id]?[.fridge] ?? 0)")
                            .fontWeight(.bold).font(.headline)
                        Text("Located in Fridge").fontWeight(.light).font(.subheadline).lineLimit(1)
                    }.foregroundStyle(.blue700)
                    Image(systemName: "house")
                        .font(.system(size: 32)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    VStack(spacing: 0) {
                        Text("\(inventory.productCountsByLocation[inventoryItem.product.id]?[.freezer] ?? 0)")
                            .fontWeight(.bold).font(.headline)
                        Text("Located in Freezer").fontWeight(.light).font(.subheadline)
                    }.foregroundStyle(.blue700)
                }
            }
        }
    }
}

struct InventoryItemSheetStatsGrid: View {
    let pageIndex: Int
    let inventoryItem: InventoryItem
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            Grid(alignment: .center, horizontalSpacing: 30, verticalSpacing: 10) {
                InventoryItemSheetStatsGridRows(pageIndex: pageIndex, inventoryItem: inventoryItem)
            }
            Grid(alignment: .center, horizontalSpacing: 10, verticalSpacing: 10) {
                InventoryItemSheetStatsGridRows(pageIndex: pageIndex, inventoryItem: inventoryItem)
            }
        }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center)
            .glassEffect(.regular.tint(inventoryItem.storageLocation.statsBackgroundTint), in: .rect(cornerRadius: 20))
    }
}

struct InventoryItemSheetView: View {
    @Environment(Inventory.self) var inventory
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    @State private var showRemoveSheet: Bool = false
    
    var inventoryItem: InventoryItem
    
    init(inventoryItem: InventoryItem) {
        self.inventoryItem = inventoryItem
        
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.blue600)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.gray150)
    }
    
    func updateInventoryItem(
        status: InventoryItemStatus? = nil,
        storageLocation: StorageLocation? = nil,
        percentageRemaining: Double? = nil)
    {
        let previousStatus = inventoryItem.status
        
        if let status {
            inventory.updateItemStatus(id: inventoryItem.id, status: status)
        }
        
        if let storageLocation {
            inventory.updateItemStorageLocation(id: inventoryItem.id, storageLocation: storageLocation)
        }
        
        Task {
            let api = KeepFreshAPI()
            
            print("percentageRemaining: \(String(describing: percentageRemaining))")
            
            do {
                try await api.updateInventoryItem(
                    for: inventoryItem.id,
                    UpdateInventoryItemRequest(
                        status: status,
                        storageLocation: storageLocation,
                        percentageRemaining: percentageRemaining))
                print("Updated inventoryItem with id: \(inventoryItem.id)")
                dismiss()
                
            } catch {
                print("Failed to update inventory item: \(error)")
                
                await MainActor.run {
                    inventory.updateItemStatus(id: inventoryItem.id, status: previousStatus)
                }
            }
        }
    }
    
    func onOpen() {
        updateInventoryItem(status: .opened)
    }
    
    func onMarkAsDone(wastePercentage: Double) {
        updateInventoryItem(status: wastePercentage == 0 ? .consumed : .discarded, percentageRemaining: wastePercentage)
    }
    
    func onMove(storageLocation: StorageLocation) {
        updateInventoryItem(storageLocation: storageLocation)
    }
    
    var body: some View {
        Group {
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray600)
                    }
                    Spacer()
                }.padding(.top, 10)
                
                GenmojiView(
                    name: inventoryItem.product.category.icon ?? "chicken",
                    fontSize: 80,
                    tint: inventoryItem.consumptionUrgency.tileColor.background)
                    .padding(.bottom, -8)
                
                Text(inventoryItem.product.name).font(.title).fontWeight(.bold).foregroundStyle(.blue700).lineLimit(2)
                    .lineSpacing(0).padding(.bottom, -8).multilineTextAlignment(.center)
                
                HStack {
                    Text(inventoryItem.product.category.name)
                        .font(.callout)
                        .foregroundStyle(.gray600)
                    if let amount = inventoryItem.product.amount, let unit = inventoryItem.product.unitFormatted {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(.gray600)
                            .padding(.horizontal, 4)
                        Text("\(String(format: "%.0f", amount))\(unit)")
                            .font(.callout)
                            .foregroundStyle(.gray600)
                    }
                }
                TabView(selection: $currentPage) {
                    ForEach(0 ..< 2, id: \.self) { page in
                        InventoryItemSheetStatsGrid(pageIndex: page, inventoryItem: inventoryItem)
                            .tag(page)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, -24)
                .padding(.horizontal, -16)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 200)
                .offset(x: 0, y: -8)
                ViewThatFits(in: .vertical) {
                    Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                        GridRow {
                            Image(systemName: "checkmark.seal.fill")
                                .fontWeight(.bold)
                                .foregroundStyle(.yellow500)
                                .font(.system(size: 32))
                            Text("Great work, you're on track to finish this before it expires")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2...2)
                            
                            Spacer()
                        }
                        GridRow {
                            Image(systemName: "cart.circle.fill")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue600)
                                .font(.system(size: 32))
                            Text("Based on your waste history for this item, you should buy this again")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2...2)
                            Spacer()
                        }
                        GridRow {
                            Image(systemName: "beach.umbrella.fill")
                                .foregroundStyle(.green500)
                                .font(.system(size: 32))
                            Text("You should only need to buy one of these before your next holiday")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2...2)
                            Spacer()
                        }
                    }.padding(.bottom, 8)
                    Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                        GridRow {
                            Image(systemName: "checkmark.seal.fill")
                                .fontWeight(.bold)
                                .foregroundStyle(.yellow500)
                                .font(.system(size: 32))
                            Text("Great work, you're on track to finish this before it expires")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2...2)
                            
                            Spacer()
                        }
                        GridRow {
                            Image(systemName: "cart.circle.fill")
                                .foregroundStyle(.blue600)
                                .font(.system(size: 32))
                            Text("Based on your waste history for this item, you should buy this again")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2...2)
                            Spacer()
                        }
                    }.padding(.bottom, 8)
                }
                Button(action: {
                    showRemoveSheet = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                            .font(.system(size: 18))
                            .frame(width: 20, alignment: .center)
                        Text("Mark as done")
                            .font(.headline)
                            .frame(width: 175, alignment: .center)
                    }
                    .foregroundStyle(.blue600)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.green300))
                }
                
                if let nextBestAction = inventoryItem.getNextBestAction(onOpen: onOpen, onMove: onMove) {
                    Button(action: nextBestAction.action) {
                        HStack(spacing: 10) {
                            Image(systemName: nextBestAction.icon)
                                .font(.system(size: 18))
                                .frame(width: 20, alignment: .center)
                            Text(nextBestAction.label)
                                .font(.headline)
                                .frame(width: 175, alignment: .center)
                        }
                        .foregroundStyle(nextBestAction.textColor)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(nextBestAction.backgroundColor))
                    }
                }
                
            }.padding(10).frame(maxWidth: .infinity, alignment: .center).ignoresSafeArea()
                .padding(.horizontal, 10)
                .sheet(isPresented: $showRemoveSheet) {
                    RemoveInventoryItemSheet(inventoryItem: inventoryItem, onMarkAsDone: onMarkAsDone)
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(25)
                        .presentationDetents([.fraction(0.4)])
                }
        }
    }
}
