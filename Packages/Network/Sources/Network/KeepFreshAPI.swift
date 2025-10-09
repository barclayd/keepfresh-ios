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

    public func getRandomProduct() async throws -> ProductSearchItemResponse {
        try await client.fetch(
            ProductSearchItemResponse.self,
            path: "v1/products/random")
    }

    public func getProduct(barcode: String) async throws -> ProductSearchItemResponse {
        try await client.fetch(
            ProductSearchItemResponse.self,
            path: "v1/products/barcode/\(barcode)")
    }

    public func getInventoryItems() async throws -> InventoryItemsResponse {
        try await client.fetch(
            InventoryItemsResponse.self,
            path: "v1/inventory")
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

    public func getInventoryPreview(_ request: InventoryPreviewRequest) async throws -> InventoryPreviewAndSuggestionsResponse {
        try await client.post(
            InventoryPreviewAndSuggestionsResponse.self,
            path: "v1/inventory/preview",
            body: request)
    }

    // MARK: - Genmoji

    public func uploadGenmoji(_ request: GenmojiUploadRequest) async throws {
        try await client.post(
            path: "v1/images/genmoji",
            body: request)
    }

    public func getGenmoji(name: String) async throws -> GenmojiGetResponse {
        try await client.fetch(
            GenmojiGetResponse.self,
            path: "v1/images/genmoji/\(name)")
    }
}
