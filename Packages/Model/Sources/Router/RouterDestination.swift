import DesignSystem
import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case today
    case search
    case kitchen
    case addConsumableItem(consumableSearchItem: ConsumableSearchItem)

    public var tint: Color? {
        switch self {
        case .addConsumableItem:
            return .white200
        case .today, .kitchen, .search:
            return nil
        }
    }
}
