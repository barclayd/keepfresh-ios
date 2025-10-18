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
                icon: "tin.open",
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
                        Text("\(inventory.productsByLocation[inventoryItem.product.id]?[.fridge]?.count ?? 0)")
                            .fontWeight(.bold).font(.headline)
                        Text("Located in Fridge").fontWeight(.light).font(.subheadline).lineLimit(1)
                    }.foregroundStyle(.blue700)
                    Image(systemName: "house")
                        .font(.system(size: 32)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    VStack(spacing: 0) {
                        Text("\(inventory.productsByLocation[inventoryItem.product.id]?[.freezer]?.count ?? 0)")
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

enum SuggestionType {
    case onTrack(ConsumptionUrgency)
    case move(StorageLocation)
    case multipleInInventory
    case relativeDate
}

func getRelativeDateInFuture(medianNumberOfDays: Double) -> String {
    let date = Calendar.current.date(byAdding: .day, value: Int(medianNumberOfDays), to: Date())!

    if date.timeUntil.totalDays == 0 {
        return "until today"
    }

    if date.timeUntil.totalDays == 1 {
        return "until tomorrow"
    }

    if date.timeUntil.totalDays < 8 {
        return "until \(date.formatted(.dateTime.weekday(.wide)))"
    }

    return "for \(date.timeUntil.formatted)"
}

@ViewBuilder
@MainActor
func suggestionView(suggestion: SuggestionType) -> some View {
    switch suggestion {
    case let .onTrack(urgency):
        switch urgency {
        case .critical:
            Suggestion(
                icon: "exclamationmark.triangle.fill",
                iconColor: .red800,
                text: "It's looking unlikely that you'll use all of this item before expiry",
                textColor: .gray600)
        case .attention:
            Suggestion(
                icon: "info.triangle.fill",
                iconColor: .yellow700,
                text: "You're not on track to use all of this item before expiry",
                textColor: .gray600)
        case .good:
            Suggestion(
                icon: "checkmark.seal.fill",
                iconColor: .green600,
                text: "Great work, you're on track to use all of this item",
                textColor: .gray600)
        }
    case .multipleInInventory:
        Suggestion(
            icon: "plus.square.fill.on.square.fill",
            iconColor: .red800,
            text: "You already have one of these in your inventory. Make sure to use that first",
            textColor: .gray600)
    case let .move(storageLocation):
        switch storageLocation {
        case .pantry:
            Suggestion(
                icon: StorageLocation.pantry.icon,
                iconColor: StorageLocation.pantry.backgroundColor,
                text: "Consider moving this item to your pantry to extend expiry",
                textColor: .gray600)
        case .fridge:
            Suggestion(
                icon: StorageLocation.fridge.icon,
                iconColor: StorageLocation.fridge.backgroundColor,
                text: "Consider moving this item to your fridge to extend expiry",
                textColor: .gray600)
        case .freezer:
            Suggestion(
                icon: StorageLocation.freezer.icon,
                iconColor: StorageLocation.freezer.backgroundColor,
                text: "Consider freezing this item before expiry to extend its shelf life",
                textColor: .gray600)
        }
    case .relativeDate:
        Suggestion(
            icon: "calendar.badge",
            iconColor: .green600,
            text: "This will likely last you \(getRelativeDateInFuture(medianNumberOfDays: 2)) at your current usage rate",
            textColor: .gray600)
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

    var storageLocationToExtendExpiry: StorageLocation? {
        guard let suggestions = SuggestionsCache.shared.getSuggestions(for: inventoryItem.product.category.id) else {
            return nil
        }

        print("suggestion: \(suggestions)")

        let pantryShelfLife = suggestions.shelfLifeInDays.unopened.pantry
        let fridgeShelfLife = suggestions.shelfLifeInDays.unopened.fridge
        let freezerShelfLife = suggestions.shelfLifeInDays.unopened.freezer

        if inventoryItem.storageLocation == .pantry,
           let pantryShelfLife,
           let fridgeShelfLife,
           fridgeShelfLife > pantryShelfLife
        {
            return .fridge
        }

        if inventoryItem.storageLocation == .pantry,
           let pantryShelfLife,
           let freezerShelfLife,
           freezerShelfLife > pantryShelfLife
        {
            return .freezer
        }

        if inventoryItem.storageLocation == .fridge,
           let fridgeShelfLife,
           let freezerShelfLife,
           freezerShelfLife > fridgeShelfLife
        {
            return .freezer
        }

        return nil
    }

    var hasEarlierExpiringDuplicate: Bool {
        let inventoryItemsForStorageLocation = inventory.productsByLocation[inventoryItem.product.id]?[inventoryItem.storageLocation] ?? []

        guard !inventoryItemsForStorageLocation.isEmpty else { return false }

        let duplicateProducts = inventoryItemsForStorageLocation.filter { $0.product.id == inventoryItem.product.id }

        guard duplicateProducts.count > 1 else { return false }

        let itemWithShorterExpiryDate = duplicateProducts.first { $0.expiryDate.timeUntil.totalDays <
            inventoryItem.expiryDate.timeUntil.totalDays
        }

        return itemWithShorterExpiryDate != nil
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
                    if let amountUnit = inventoryItem.product.amountUnitFormatted {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(.gray600)
                            .padding(.horizontal, 4)
                        Text(amountUnit)
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

                Grid(alignment: .center, horizontalSpacing: 16, verticalSpacing: 20) {
                    suggestionView(suggestion: .onTrack(inventoryItem.consumptionUrgency))

                    if hasEarlierExpiringDuplicate {
                        suggestionView(suggestion: .multipleInInventory)
                    }
//                    else if inventoryItem.consumptionUrgency == .good {
//                        // TODO: make request to get medianExpiryDate
//                        suggestionView(suggestion: .relativeDate)
//                    }
                    else if let suggestedStorageLocation = storageLocationToExtendExpiry {
                        suggestionView(suggestion: .move(suggestedStorageLocation))
                    }
                }.padding(.bottom, 8)

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
                            if nextBestAction.icon == "tin.open" {
                                Image("tin.open")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            } else {
                                Image(systemName: nextBestAction.icon)
                                    .font(.system(size: 18))
                                    .frame(width: 20, alignment: .center)
                            }

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
                        .presentationDetents(
                            inventoryItem.product.name
                                .count >= 20 ? [.custom(AdaptiveSmallDetent.self)] : [.custom(AdaptiveExtraSmallDetent.self)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(25)
                }
        }
    }
}
