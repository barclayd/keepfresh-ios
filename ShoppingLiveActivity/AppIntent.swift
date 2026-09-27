import AppIntents
import Models

struct ShoppingWidgetIntents: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] { [ShoppingActivityIntents.self] }
}
