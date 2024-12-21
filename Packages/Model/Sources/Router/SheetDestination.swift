import Models
import SwiftUI

public enum SheetDestination: Hashable, Identifiable {
    public var id: Int { hashValue }

    case groceryItem(groceryItemId: String)
}
