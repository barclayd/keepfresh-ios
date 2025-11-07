import Foundation
import StoreKit

enum AppEnvironment {
    static func detect() async -> String {
        #if targetEnvironment(simulator)
            return "development"
        #endif

        do {
            _ = try await AppTransaction.shared
            return "production"
        } catch {
            return "development"
        }
    }
}
