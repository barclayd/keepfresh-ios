import Models
import SwiftUI

public enum SheetDestination: Hashable, Identifiable {
    public var id: Int { hashValue }

    case consumableItem(consumableItemId: String)
}
