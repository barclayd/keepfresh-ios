import DesignSystem
import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case today
    case search
    case barcodeScan
    case kitchen
    case addProduct(product: ProductSearchItem)
    case inventoryStoreView(inventoryStore: InventoryStoreDetails)

    public var tint: Color? {
        switch self {
        case .addProduct, .inventoryStoreView:
            return .white200
        case .today, .kitchen, .search, .barcodeScan:
            return nil
        }
    }

    public var tabBarVisibility: Visibility {
        switch self {
        case .addProduct:
            return .hidden
        default:
            return .visible
        }
    }
}
