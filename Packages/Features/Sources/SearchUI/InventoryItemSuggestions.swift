import Foundation
import Models
import Network

@MainActor
@Observable
public class InventoryItemSuggestions {
    private static var globalCache: [Int: InventoryPreviewAndSuggestionsResponse] = [:]

    public enum LoadingState {
        case idle
        case loading
        case loaded(InventoryPreviewAndSuggestionsResponse)
        case failed(Error)
    }

    public var state: LoadingState = .idle

    public var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    public var suggestions: InventorySuggestionsResponse? {
        if case let .loaded(response) = state {
            return response.suggestions
        }
        return nil
    }

    public var predictions: InventoryPredictionsResponse? {
        if case let .loaded(response) = state {
            return response.predictions
        }
        return nil
    }

    public var error: Error? {
        if case let .failed(error) = state { return error }
        return nil
    }

    private var currentCategoryId: Int?

    public init() {}

    public func fetchInventorySuggestions(product: InventoryPreviewRequest.PreviewProduct) async {
        let categoryId = product.categoryId

        if currentCategoryId != categoryId {
            currentCategoryId = categoryId
            state = .idle
        }

        if let cachedSuggestions = Self.globalCache[categoryId] {
            state = .loaded(cachedSuggestions)
            print("Using cached inventory preview for category: \(categoryId)")
            return
        }

        state = .loading

        let api = KeepFreshAPI()

        do {
            let request = InventoryPreviewRequest(product: product)
            let response = try await api.getInventoryPreview(request)

            Self.globalCache[categoryId] = response

            if currentCategoryId == categoryId {
                state = .loaded(response)
            }

            print("Fetched inventory preview for category: \(categoryId)")

        } catch {
            if currentCategoryId == categoryId {
                state = .failed(error)
            }
            print("Failed to fetch inventory preview: \(error)")
        }
    }

    public func getCachedSuggestions(for categoryId: Int) -> InventorySuggestionsResponse? {
        Self.globalCache[categoryId]?.suggestions
    }

    public func getCachedPredictions(for categoryId: Int) -> InventoryPredictionsResponse? {
        Self.globalCache[categoryId]?.predictions
    }

    public static func clearGlobalCache() {
        globalCache.removeAll()
    }

    public func reset() {
        currentCategoryId = nil
        state = .idle
    }
}
