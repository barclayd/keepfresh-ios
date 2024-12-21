import KitchenUI
import Router
import SearchUI
import SwiftUI
import TodayUI

public struct AppRouter: ViewModifier {
    @Binding var searchText: String

    public init(searchText: Binding<String>) {
        _searchText = searchText
    }

    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { destination in
                switch destination {
                case .kitchen:
                    KitchenView()
                case .search:
                    SearchView(searchText: $searchText)
                case .today:
                    TodayView()
                }
            }
    }
}

public extension View {
    func withAppRouter(searchText: Binding<String>) -> some View {
        modifier(AppRouter(searchText: searchText))
    }
}
