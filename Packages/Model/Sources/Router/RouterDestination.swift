import DesignSystem
import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case today
    case search
    case kitchen
    case addGroceryItem(grocerySearchItem: GrocerySearchItem)

    public var tint: Color? {
        switch self {
        case .addGroceryItem:
            return .white200
        case .today, .kitchen, .search:
            return nil
        }
    }
}
