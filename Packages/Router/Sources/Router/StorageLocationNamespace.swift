import SwiftUI

private struct StorageLocationNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

public extension EnvironmentValues {
    var storageLocationNamespace: Namespace.ID? {
        get { self[StorageLocationNamespaceKey.self] }
        set { self[StorageLocationNamespaceKey.self] = newValue }
    }
}
