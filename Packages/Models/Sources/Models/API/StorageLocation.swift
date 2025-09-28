import DesignSystem
import SwiftUI

public enum StorageLocation: String, Codable, Identifiable, CaseIterable, Equatable, Sendable {
    public var id: Self { self }

    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"

    public var icon: String {
        switch self {
        case .pantry: "cabinet"
        case .fridge: "refrigerator"
        case .freezer: "snowflake.circle"
        }
    }

    public var iconFilled: String { "\(icon).fill" }

    public var previewGradientStops: (start: Color, end: Color) {
        switch self {
        case .pantry: (.brown100, .brown300)
        case .fridge: (.blue50, .blue600)
        case .freezer: (.blue600, .blue700)
        }
    }

    public var viewGradientStops: [Gradient.Stop] {
        switch self {
        case .pantry:
            [
                Gradient.Stop(color: .brown300, location: 0),
                Gradient.Stop(color: .brown100, location: 0.2),
                Gradient.Stop(color: .white200, location: 0.375),
            ]
        case .fridge:
            [
                Gradient.Stop(color: .blue700, location: 0),
                Gradient.Stop(color: .blue500, location: 0.2),
                Gradient.Stop(color: .white200, location: 0.375),
            ]
        case .freezer:
            [
                Gradient.Stop(color: .blue800, location: 0),
                Gradient.Stop(color: .blue600, location: 0.25),
                Gradient.Stop(color: .white200, location: 0.375),
            ]
        }
    }

    public var foregorundColor: Color {
        switch self {
        case .pantry, .fridge: .gray700
        case .freezer: .gray100
        }
    }

    public var expiryIconColor: Color {
        switch self {
        case .pantry, .fridge: .blue700
        case .freezer: .blue100
        }
    }
}
