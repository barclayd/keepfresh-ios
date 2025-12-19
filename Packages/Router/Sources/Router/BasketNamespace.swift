import SwiftUI

private struct BasketNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

public extension EnvironmentValues {
    var basketNamespace: Namespace.ID? {
        get { self[BasketNamespaceKey.self] }
        set { self[BasketNamespaceKey.self] = newValue }
    }
}
