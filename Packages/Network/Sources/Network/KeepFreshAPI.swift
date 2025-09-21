import Foundation
import Models

public struct KeepFreshAPI {
    private let client: APIClient

    public init(baseURL: String = "https://api.keepfre.sh") {
        client = APIClient(baseURL: baseURL)
    }

    // MARK: - Products

    public func searchProducts(query: String) async throws -> ProductSearchResponse {
        try await client.fetch(
            ProductSearchResponse.self,
            path: "v1/products",
            queryParameters: ["search": query]
        )
    }

    // MARK: - Categories

    public func getInventorySuggestions(categoryId: Int) async throws -> InventorySuggestionsResponse {
        try await client.fetch(
            InventorySuggestionsResponse.self,
            path: "v1/categories/\(categoryId)/inventory-suggestions"
        )
    }

    // MARK: - Inventory

    public func createInventoryItem(_ request: AddInventoryItemRequest) async throws -> AddInventoryItemResponse {
        try await client.post(
            AddInventoryItemResponse.self,
            path: "v1/inventory/items",
            body: request
        )
    }
}
