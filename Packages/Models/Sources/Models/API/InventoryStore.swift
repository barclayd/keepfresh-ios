import DesignSystem
import SwiftUI

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

    public var iconFilled: String { "\(icon).fill" }
    
    
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
    
    public var expiryIconColor: Color {
        switch self {
        case .pantry, .fridge: return .blue700
        case .freezer: return .blue100
        }
    }
}
