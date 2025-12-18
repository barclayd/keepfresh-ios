import SwiftUI

private struct ShoppingModeNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

public extension EnvironmentValues {
    var shoppingModeNamespace: Namespace.ID? {
        get { self[ShoppingModeNamespaceKey.self] }
        set { self[ShoppingModeNamespaceKey.self] = newValue }
    }
}
