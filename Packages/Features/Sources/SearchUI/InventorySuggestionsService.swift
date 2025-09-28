import Foundation
import Models
import Network

@MainActor
@Observable
public class InventoryItemSuggestions {
    private static var globalCache: [Int: InventorySuggestionsResponse] = [:]

    public enum LoadingState {
        case idle
        case loading
        case loaded(InventorySuggestionsResponse)
        case failed(Error)
    }

    public var state: LoadingState = .idle

    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    public var suggestions: InventorySuggestionsResponse? {
        if case let .loaded(response) = state { return response }
        return nil
    }

    public var error: Error? {
        if case let .failed(error) = state { return error }
        return nil
    }

    private var currentCategoryId: Int?

    public init() {}

    public func fetchInventorySuggestions(for categoryId: Int) async {
        if currentCategoryId != categoryId {
            currentCategoryId = categoryId
            state = .idle
        }

        if let cachedSuggestions = Self.globalCache[categoryId] {
            state = .loaded(cachedSuggestions)
            print("Using cached inventory suggestions for category: \(categoryId)")
            return
        }

        state = .loading

        let api = KeepFreshAPI()

        do {
            let response = try await api.getInventorySuggestions(categoryId: categoryId)

            Self.globalCache[categoryId] = response

            if currentCategoryId == categoryId {
                state = .loaded(response)
            }

            print("Fetched inventory suggestions for category: \(categoryId)")

        } catch {
            if currentCategoryId == categoryId {
                state = .failed(error)
            }
            print("Failed to fetch inventory suggestions: \(error)")
        }
    }

    public func getCachedSuggestions(for categoryId: Int) -> InventorySuggestionsResponse? {
        Self.globalCache[categoryId]
    }

    public static func clearGlobalCache() {
        globalCache.removeAll()
    }

    public func reset() {
        currentCategoryId = nil
        state = .idle
    }
}
