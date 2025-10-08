import DesignSystem
import SwiftUI

public extension EnvironmentValues {
    @Entry var currentTab: AppTab = .today
}

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case today, kitchen, search, debug

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .today: "text.rectangle.page"
        case .search: "magnifyingglass"
        case .kitchen: "refrigerator"
        case .debug: "hammer"
        }
    }

    public var symbolVariants: SymbolVariants {
        switch self {
        case .today: .none
        case .search: .fill
        case .kitchen: .none
        case .debug: .fill
        }
    }

    public var title: String {
        switch self {
        case .today: "Today"
        case .search: "Search"
        case .kitchen: "Kitchen"
        case .debug: "Debug"
        }
    }

    public var toolbarBackground: Color {
        switch self {
        case .today: .clear
        case .search: .blue600
        case .kitchen: .clear
        case .debug: .clear
        }
    }
}
