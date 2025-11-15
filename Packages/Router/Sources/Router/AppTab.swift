import DesignSystem
import SwiftUI

public extension EnvironmentValues {
    @Entry var currentTab: AppTab = .today
}

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case today, kitchen, search, shoppingList
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .today: "text.rectangle.page"
        case .search: "magnifyingglass"
        case .kitchen: "refrigerator"
        case .shoppingList: "cart"
        }
    }
    
    public var symbolVariants: SymbolVariants {
        switch self {
        case .today: .none
        case .search: .fill
        case .kitchen: .none
        case .shoppingList: .fill
        }
    }
    
    public var title: String {
        switch self {
        case .today: "Today"
        case .search: "Search"
        case .kitchen: "Kitchen"
        case .shoppingList: "Shopping"
        }
    }
    
    public var toolbarBackground: Color {
        switch self {
        case .today, .kitchen, .shoppingList:
            .clear
        case .search:
            .blue600
        }
    }
}
