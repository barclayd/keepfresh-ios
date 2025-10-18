import Foundation

@MainActor
public class SuggestionsCache {
    private(set) var suggestions: [Int: InventorySuggestionsResponse] = [:]
    private let fileName = "suggestionsData.json"
    
    public static let shared = SuggestionsCache()
    
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
    
    public init() {}
    
    public func load() async {
        guard suggestions.isEmpty else { return }
        
        if let fileData = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Int: InventorySuggestionsResponse].self, from: fileData)
        {
            suggestions = decoded
        }
    }
    
    func saveData() async {
        let dataToSave = suggestions
        let url = fileURL
        
        await Task.detached {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let jsonData = try encoder.encode(dataToSave)
                try jsonData.write(to: url, options: .atomic)
            } catch {
                print("Failed to save suggestions data: \(error)")
            }
        }.value
    }
       
    public func getSuggestions(for categoryId: Int) async -> InventorySuggestionsResponse? {
        if suggestions.isEmpty {
            await load()
        }
        
        return suggestions[categoryId]
    }
       
    public func saveSuggestions(categoryId: Int, categorySuggestions: InventorySuggestionsResponse) async {
        if suggestions.isEmpty {
            await load()
        }
        
        suggestions[categoryId] = categorySuggestions
           
        await saveData()
    }
}
