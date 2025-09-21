import SwiftUI
import DesignSystem

public enum InventoryStore: String, Codable, Identifiable, CaseIterable, Equatable, Sendable {
    public var id: Self { self }
    
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"
    
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
