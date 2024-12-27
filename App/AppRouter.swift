import KitchenUI
import Router
import SearchUI
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
                case let .addConsumableItem(consumableSearchItem):
                    AddConsumableView(consumableSearchItem: consumableSearchItem)
                }
            }
    }
}

public extension View {
    func withAppRouter() -> some View {
        modifier(AppRouter())
    }
}
