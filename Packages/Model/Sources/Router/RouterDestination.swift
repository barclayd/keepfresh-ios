import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case today
    case search
    case kitchen
    case addGroceryItem(grocerySearchItem: GrocerySearchItem)
}
