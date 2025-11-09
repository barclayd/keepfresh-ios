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
        case .freezer: "snowflake"
        }
    }

    public var iconFilled: String {
        self == .freezer ? icon : "\(icon).fill"
    }

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
                Gradient.Stop(color: .brown100, location: 0.4),
                Gradient.Stop(color: .white200, location: 0.75),
            ]
        case .fridge:
            [
                Gradient.Stop(color: .blue700, location: 0),
                Gradient.Stop(color: .blue500, location: 0.4),
                Gradient.Stop(color: .white200, location: 0.75),
            ]
        case .freezer:
            [
                Gradient.Stop(color: .blue800, location: 0),
                Gradient.Stop(color: .blue700, location: 0.4),
                Gradient.Stop(color: .blue600, location: 1),
            ]
        }
    }

    public var foregroundColor: Color {
        switch self {
        case .pantry: .brown900
        case .fridge: .blue800
        case .freezer: .white200
        }
    }

    public var titleColor: Color {
        switch self {
        case .pantry: .brown900
        case .fridge: .blue700
        case .freezer: .blue800
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .pantry: .brown300
        case .fridge: .blue700
        case .freezer: .blue800
        }
    }

    public var expiryIconColor: Color {
        switch self {
        case .pantry, .fridge: .blue700
        case .freezer: .blue100
        }
    }

    public var tileColor: Color {
        switch self {
        case .pantry: .brown300
        case .fridge: .blue400
        case .freezer: .blue800
        }
    }

    public var textColor: Color {
        switch self {
        case .pantry: .blue800
        case .fridge: .white200
        case .freezer: .white200
        }
    }

    public var infoColor: Color {
        switch self {
        case .pantry: .gray600
        case .fridge: .white400
        case .freezer: .gray200
        }
    }

    public var statsBackgroundTint: Color {
        switch self {
        case .pantry: .brown100
        case .fridge: .blue100
        case .freezer: .blue100
        }
    }
}
