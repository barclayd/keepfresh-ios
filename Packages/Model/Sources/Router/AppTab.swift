import SwiftUI

public extension EnvironmentValues {
    @Entry var currentTab: AppTab = .search
}

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case search

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .search: return "square.stack"
        }
    }
}
