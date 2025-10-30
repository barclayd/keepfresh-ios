import DesignSystem
import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case today
    case search
    case barcodeScan
    case kitchen
    case addProduct(product: ProductSearchResultItemResponse)
    case storageLocationView(storageLocation: StorageLocation)

    public var tint: Color? {
        switch self {
        case .addProduct, .storageLocationView:
            .white200
        case .today, .kitchen, .search, .barcodeScan:
            nil
        }
    }

    public var tabBarVisibility: Visibility {
        switch self {
        case .addProduct:
            .hidden
        default:
            .visible
        }
    }
}
