import DesignSystem
import SwiftUI

public enum InventoryStore: String, Codable, Identifiable, CaseIterable {
    public var id: Self { self }

    case pantry
    case fridge
    case freezer

    public var icon: String {
        switch self {
        case .pantry: return "cabinet"
        case .fridge: return "refrigerator"
        case .freezer: return "snowflake.circle"
        }
    }

    public var previewGradientStops: (start: Color, end: Color) {
        switch self {
        case .pantry: return (.brown100, .brown300)
        case .fridge: return (.blue50, .blue600)
        case .freezer: return (.blue600, .blue700)
        }
    }

    public var viewGradientStops: [Gradient.Stop] {
        switch self {
        case .pantry:
            return [
                Gradient.Stop(color: .brown300, location: 0),
                Gradient.Stop(color: .brown100, location: 0.2),
                Gradient.Stop(color: .white200, location: 0.375),
            ]
        case .fridge:
            return [
                Gradient.Stop(color: .blue700, location: 0),
                Gradient.Stop(color: .blue500, location: 0.2),
                Gradient.Stop(color: .white200, location: 0.375),
            ]
        case .freezer:
            return [
                Gradient.Stop(color: .blue800, location: 0),
                Gradient.Stop(color: .blue600, location: 0.25),
                Gradient.Stop(color: .white200, location: 0.375),
            ]
        }
    }

    public var foregorundColor: Color {
        switch self {
        case .pantry, .fridge: return .gray700
        case .freezer: return .gray100
        }
    }

    public var titleForegorundColor: Color {
        switch self {
        case .pantry, .fridge: return .blue700
        case .freezer: return .blue100
        }
    }

    public var expiryIconColor: Color {
        switch self {
        case .pantry, .fridge: return .blue700
        case .freezer: return .blue100
        }
    }
}

public struct InventoryStoreDetails: Identifiable, Hashable {
    public init(
        id: Int, name: String, type: InventoryStore, expiryStatusPercentage: Float, lastUpdated: Date,
        itemsCount: Int, openItemsCount: Int, itemsExpiringSoonCount: Int, recentItemImages: [String]
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.expiryStatusPercentage = expiryStatusPercentage
        self.lastUpdated = lastUpdated
        self.itemsCount = itemsCount
        self.openItemsCount = openItemsCount
        self.itemsExpiringSoonCount = itemsExpiringSoonCount
        self.recentItemImages = recentItemImages
    }

    public var id: Int
    public var name: String
    public var type: InventoryStore
    public var expiryStatusPercentage: Float
    public var lastUpdated: Date
    public var itemsCount: Int
    public var openItemsCount: Int
    public var itemsExpiringSoonCount: Int
    public var recentItemImages: [String]

    public var expiryStatusPercentageColor: Color {
        switch expiryStatusPercentage {
        case 0 ... 33: return .green600
        case 33 ... 66: return .yellow400
        default: return .red500
        }
    }
}

public enum InventoryItemStatus: String, Codable, Identifiable, CaseIterable {
    public var id: Self { self }

    case open
    case binned
    case consumed
    case unopened
}

public struct ProductSearchItemCategory: Identifiable, Codable, Equatable, Hashable {
    public init(id: Int, name: String, path: String) {
        self.id = id
        self.name = name
        self.path = path
    }
    
    public let id: Int
    public let name: String
    public let path: String
}

public struct ProductSearchItem: Identifiable, Hashable, Codable {
    public init(
        sourceId: String, imageURL: String, name: String, category: ProductSearchItemCategory, brand: String,
        amount: Double?,
        unit: String?
    ) {
        self.sourceId = sourceId
        self.imageURL = imageURL
        self.name = name
        self.category = category
        self.brand = brand
        self.amount = amount
        self.unit = unit
    }

    public let sourceId: String
    public let imageURL: String
    public let name: String
    public let category: ProductSearchItemCategory
    public let brand: String
    public let amount: Double?
    public let unit: String?

    public var id: String {
        "\(sourceId)-\(brand)"
    }
}

public struct InventoryItem: Identifiable {
    public init(
        id: UUID, imageURL: String, name: String, category: String, brand: String, amount: Double,
        unit: String, inventoryStore: InventoryStore, status: InventoryItemStatus, wasteScore: Double,
        expiryDate: Date? = nil
    ) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.category = category
        self.brand = brand
        self.amount = amount
        self.unit = unit
        self.inventoryStore = inventoryStore
        self.status = status
        self.wasteScore = wasteScore
        self.expiryDate = expiryDate
    }

    public let id: UUID
    public let imageURL: String
    public let name: String
    public let category: String
    public let brand: String
    public let amount: Double
    public let unit: String
    public let inventoryStore: InventoryStore
    public let status: InventoryItemStatus
    public let wasteScore: Double
    public let expiryDate: Date?
}
