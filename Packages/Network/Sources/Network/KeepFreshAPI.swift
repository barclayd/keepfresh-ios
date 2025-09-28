import Foundation
import Models

public struct KeepFreshAPI: Sendable {
    private let client: APIClient

    public init(baseURL: String = "https://api.keepfre.sh") {
        client = APIClient(baseURL: baseURL)
    }

    // MARK: - Products

    public func searchProducts(query: String) async throws -> ProductSearchResponse {
        try await client.fetch(
            ProductSearchResponse.self,
            path: "v1/products",
            queryParameters: ["search": query])
    }

    // MARK: - Categories

    public func getInventorySuggestions(categoryId: Int) async throws -> InventorySuggestionsResponse {
        try await client.fetch(
            InventorySuggestionsResponse.self,
            path: "v1/categories/\(categoryId)/inventory-suggestions")
    }

    public func getInventoryItems() async throws -> InventoryItemsResponse {
        try await client.fetch(
            InventoryItemsResponse.self,
            path: "v1/inventory",
            queryParameters: nil)
    }

    // MARK: - Inventory

    public func createInventoryItem(_ request: AddInventoryItemRequest) async throws -> AddInventoryItemResponse {
        try await client.post(
            AddInventoryItemResponse.self,
            path: "v1/inventory/items",
            body: request)
    }

    public func updateInventoryItem(for itemId: Int, _ request: UpdateInventoryItemRequest) async throws {
        try await client.patch(path: "v1/inventory/items/\(itemId)", body: request)
    }
}
