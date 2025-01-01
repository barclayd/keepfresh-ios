import DesignSystem
import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case today
    case search
    case kitchen
    case addConsumableItem(consumableSearchItem: ConsumableSearchItem)
    case inventoryStoreView(inventoryStore: InventoryStoreDetails)

    public var tint: Color? {
        switch self {
        case .addConsumableItem, .inventoryStoreView:
            return .white200
        case .today, .kitchen, .search:
            return nil
        }
    }
}
