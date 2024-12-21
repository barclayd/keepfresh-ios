import InventoryUI
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
                    InventoryView()
                case .search:
                    SearchView()
                case .today:
                    TodayView()
                }
            }
    }
}

public extension View {
    func withAppRouter() -> some View {
        modifier(AppRouter())
    }
}
