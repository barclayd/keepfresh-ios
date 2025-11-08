import Foundation

enum AppEnvironment {
    static func detect() -> String {
        #if targetEnvironment(simulator)
            return "development"
        #endif

        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return "development"
        }

        let path = receiptURL.path
        if path.contains("sandboxReceipt") || path.contains("/receipt") {
            return "production"
        }

        return "development"
    }
}
