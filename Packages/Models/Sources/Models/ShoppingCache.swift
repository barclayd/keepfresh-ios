import Foundation

@MainActor
public class ShoppingCache {
    private(set) var items: [ShoppingItem] = []
    private let fileName = "shoppingData.json"

    public static let shared = ShoppingCache()

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    public init() {}

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
        items = newItems
        let dataToSave = newItems
        let url = fileURL

        await Task.detached {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let jsonData = try encoder.encode(dataToSave)
                try jsonData.write(to: url, options: .atomic)
            } catch {
                print("Failed to save shopping data: \(error)")
            }
        }.value
    }
}
