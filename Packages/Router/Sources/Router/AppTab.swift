import DesignSystem
import SwiftUI

public extension EnvironmentValues {
    @Entry var currentTab: AppTab = .today
}

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case today, kitchen, search, shoppingList, shoppingListSearch
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .today: "text.rectangle.page"
        case .search: "magnifyingglass"
        case .kitchen: "refrigerator"
        case .shoppingList: "cart"
        case .shoppingListSearch: "plus"
        }
    }
    
    public var symbolVariants: SymbolVariants {
        switch self {
        case .today: .none
        case .search: .fill
        case .kitchen: .none
        case .shoppingList: .fill
        case .shoppingListSearch: .none
        }
    }
    
    public var title: String {
        switch self {
        case .today: "Today"
        case .search: "Search"
        case .kitchen: "Kitchen"
        case .shoppingList: "Shopping"
        case .shoppingListSearch: "Search"
        }
    }
    
    public var toolbarBackground: Color {
        switch self {
        case .today, .kitchen, .shoppingList:
            .clear
        case .search, .shoppingListSearch:
            .blue600
        }
    }
}
