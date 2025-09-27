import DesignSystem
import Extensions
import Models
import Network
import SwiftUI

public enum FetchState {
    case empty
    case loading
    case loaded
    case error
}

public struct InventoryLocationDetails: Hashable {
    public var expiryPercentage: Int
    public var lastUpdated: Date?
    public var expiringSoonCount: Int
    public var recentlyUpdatedImages: [String]
    public var openItemsCount: Int
    public var itemsCount: Int
    public var recentlyAddedItemsCount: Int
    public var expiringTodayCount: Int

    public var expiryStatusPercentageColor: Color {
        switch expiryPercentage {
        case 0 ... 33: .green600
        case 33 ... 66: .yellow400
        default: .red500
        }
    }

    struct InventoryStat: Identifiable {
        var icon: String
        var label: String

        var id: String { icon }
    }
}

@Observable
@MainActor
public final class Inventory {
    public var items: [InventoryItem] = [] {
        didSet {
            updateCaches()
        }
    }

    public var state: FetchState = .empty

    let api = KeepFreshAPI()

    public private(set) var itemsByLocation: [InventoryStore: [InventoryItem]] = [:]
    public private(set) var productCounts: [Int: Int] = [:]
    public private(set) var productCountsByLocation: [Int: [InventoryStore: Int]] = [:]
    public private(set) var detailsByLocation: [InventoryStore: InventoryLocationDetails] = [:]

    public init() {}

    private func updateCaches() {
        itemsByLocation = Dictionary(grouping: items, by: \.storageLocation)

        detailsByLocation = itemsByLocation.mapValues { items in
            InventoryLocationDetails(expiryPercentage: 59, lastUpdated: items.map(\.createdAt).max(), expiringSoonCount: items.count(where: { $0.expiryDate.timeUntil.totalDays < 4 }), recentlyUpdatedImages: ["popcorn.fill", "birthday.cake.fill", "carrot.fill"], openItemsCount: items.count(where: { $0.openedAt != nil }), itemsCount: items.count, recentlyAddedItemsCount: items.count(where: { $0.createdAt.timeSince.totalDays < 4 }), expiringTodayCount: items.count(where: { $0.expiryDate.timeUntil.totalDays == 0 }))
        }

        var counts: [Int: Int] = [:]
        var locationCounts: [Int: [InventoryStore: Int]] = [:]

        for item in items {
            counts[item.id, default: 0] += 1
            locationCounts[item.id, default: [:]][item.storageLocation, default: 0] += 1
        }

        productCounts = counts
        productCountsByLocation = locationCounts
    }

    public var itemsSortedByRecentlyAddedDescending: [InventoryItem] {
        items.sorted { $0.createdAt > $1.createdAt }
    }

    public var itemsSortedByExpiryDescending: [InventoryItem] {
        items.sorted { $0.expiryDate < $1.expiryDate }
    }

    public func fetchItems() async {
        state = .loading

        do {
            items = try await api.getInventoryItems().inventoryItems
            print("item length: \(items.count)")
        } catch {
            state = .error
            return
        }

        state = .loaded
    }
}
