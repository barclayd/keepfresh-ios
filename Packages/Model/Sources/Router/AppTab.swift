import SwiftUI

public extension EnvironmentValues {
    @Entry var currentTab: AppTab = .today
}

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case today, search, kitchen

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .today: return "text.rectangle.page"
        case .search: return "magnifyingglass"
        case .kitchen: return "refrigerator"
        }
    }

    public var title: String {
        switch self {
        case .today: return "Today"
        case .search: return "Search"
        case .kitchen: return "Kitchen"
        }
    }

    @ViewBuilder
    public var label: some View {
        Label(title, systemImage: icon)
            .environment(\.symbolVariants, self == .today ? .none : .fill)
    }
}
