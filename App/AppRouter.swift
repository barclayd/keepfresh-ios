import Router
import SwiftUI

public struct AppRouter: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { _ in
                Text("Hello")
            }
    }
}

public extension View {
    func withAppRouter() -> some View {
        modifier(AppRouter())
    }
}
