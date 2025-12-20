import SwiftUI

private struct InventoryItemNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

public extension EnvironmentValues {
    var inventoryItemNamespace: Namespace.ID? {
        get { self[InventoryItemNamespaceKey.self] }
        set { self[InventoryItemNamespaceKey.self] = newValue }
    }
}
