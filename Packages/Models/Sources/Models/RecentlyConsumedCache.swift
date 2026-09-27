import Foundation

@MainActor
public class RecentlyConsumedCache {
    private(set) var items: [InventoryItem] = []
    private let fileName = "recentlyConsumedData.json"

    public static let shared = RecentlyConsumedCache()

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    public init() {}

    public func load() -> [InventoryItem] {
        if let fileData = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: fileData)
        {
            items = decoded
            return decoded
        }
        return []
    }

    public func save(_ newItems: [InventoryItem]) async {
        items = newItems
        let dataToSave = newItems
        let url = fileURL

        // Serialize atomic writes so an older save cannot overwrite a refreshed cache.
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(dataToSave)
            try jsonData.write(to: url, options: .atomic)
        } catch {
            print("Failed to save recently consumed data: \(error)")
        }
    }
}
