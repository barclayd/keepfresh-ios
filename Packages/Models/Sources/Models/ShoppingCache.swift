import Foundation

@MainActor
public class ShoppingCache {
    public private(set) var items: [ShoppingItem] = []
    public var onExternalChange: (@MainActor ([ShoppingItem]) -> Void)?
    private let fileName = "shoppingData.json"
    private let persistenceURL: URL?

    public static let shared = ShoppingCache()

    private var fileURL: URL {
        persistenceURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    public init(fileURL: URL? = nil) {
        persistenceURL = fileURL
    }

    public func load() -> [ShoppingItem] {
        if let fileData = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: fileData)
        {
            items = decoded
            return decoded
        }
        return []
    }

    public func save(_ newItems: [ShoppingItem]) async {
        do { try saveImmediately(newItems) }
        catch { print("Failed to save shopping data: \(error)") }
    }

    /// Commit in order before accepting a lock-screen action or suspending the app.
    public func saveImmediately(_ newItems: [ShoppingItem]) throws {
        let jsonData = try JSONEncoder().encode(newItems)
        try jsonData.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        items = newItems
    }
}
