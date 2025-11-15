import BarcodeUI
import KitchenUI
import Router
import SearchUI
import ShoppingUI
import SwiftUI
import TodayUI

public struct AppRouter: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { destination in
                switch destination {
                case .kitchen:
                    KitchenView()
                case .search:
                    SearchView()
                case .today:
                    TodayView()
                case .shopping:
                    ShoppingView()
                case let .addProduct(productSearchItem):
                    AddInventoryItemView(productSearchItem: productSearchItem)
                case let .storageLocationView(storageLocation):
                    StorageLocationView(storageLocation: storageLocation)
                case .barcodeScan:
                    BarcodeView()
                }
            }
    }
}

public extension View {
    func withAppRouter() -> some View {
        modifier(AppRouter())
    }
}
