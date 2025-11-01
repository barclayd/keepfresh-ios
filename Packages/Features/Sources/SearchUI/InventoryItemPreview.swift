import Foundation
import Models
import Network

@MainActor
@Observable
public class InventoryItemPreview {
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

    public init() {}

    public func fetchInventorySuggestions(categoryId: Int, productId: Int) async {
        state = .loading

        let api = KeepFreshAPI()

        do {
            let response = try await api.getInventoryPreview(categoryId: categoryId, productId: productId)

            state = .loaded(response)

            print("Fetched inventory preview for category: \(categoryId)")

        } catch {
            state = .failed(error)
            print("Failed to fetch inventory preview: \(error)")
        }
    }

    public func reset() {
        state = .idle
    }
}
