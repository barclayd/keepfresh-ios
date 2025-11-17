import Foundation
import Models

public struct KeepFreshAPI: Sendable {
    private let client: APIClient

    public init(baseURL: String = "https://feat-shopping-item-complete-endpoint-keepfresh-api.barclaysd.workers.dev/") {
        client = APIClient(baseURL: baseURL)
    }

    // MARK: - Products

    public func searchProducts(query: String, page: Int = 1, country: String = "GB") async throws -> ProductSearchResponse {
        try await client.fetch(
            ProductSearchResponse.self,
            path: "v2/products",
            queryParameters: [
                "search": query,
                "country": country,
                "page": String(page),
            ])
    }

    public func getRandomProduct() async throws -> ProductSearchResultItemResponse {
        try await client.fetch(
            ProductSearchResultItemResponse.self,
            path: "v2/products/random")
    }

    public func getProduct(barcode: String) async throws -> ProductSearchResultItemResponse {
        try await client.fetch(
            ProductSearchResultItemResponse.self,
            path: "v2/products/barcode/\(barcode)")
    }

    public func getProductUsageStats(productId: Int) async throws -> ProductUsageStatsResponse {
        try await client.fetch(
            ProductUsageStatsResponse.self,
            path: "v1/products/\(productId)/stats")
    }

    public func getInventoryItems() async throws -> [InventoryItem] {
        try await client.fetch(
            [InventoryItem].self,
            path: "v1/inventory")
    }

    // MARK: - Inventory

    public func addInventoryItem(_ request: AddInventoryItemRequest) async throws -> AddInventoryItemResponse {
        try await client.post(
            AddInventoryItemResponse.self,
            path: "v2/inventory/items",
            body: request)
    }

    public func updateInventoryItem(for itemId: Int, _ request: UpdateInventoryItemRequest) async throws {
        try await client.patch(path: "v2/inventory/items/\(itemId)", body: request)
    }

    public func getInventoryPreview(categoryId: Int, productId: Int) async throws -> InventoryPreviewAndSuggestionsResponse {
        try await client.fetch(
            InventoryPreviewAndSuggestionsResponse.self,
            path: "v2/inventory/items/preview",
            queryParameters: [
                "categoryId": String(categoryId),
                "productId": String(productId),
            ])
    }

    public func deleteInventoryItem(for itemId: Int) async throws {
        try await client.delete(path: "v2/inventory/items/\(itemId)")
    }

    // MARK: - Shopping

    public func getShoppingItems() async throws -> [ShoppingItem] {
        try await client.fetch(
            [ShoppingItem].self,
            path: "v2/shopping")
    }

    public func addShoppingItem(_ request: AddShoppingItemRequest) async throws -> [ShoppingItem] {
        try await client.post(
            [ShoppingItem].self,
            path: "v2/shopping/items",
            body: request)
    }

    public func updateShoppingItem(for shoppingItemId: Int, _ request: UpdateShoppingItemRequest) async throws {
        try await client.patch(path: "v2/shopping/items/\(shoppingItemId)", body: request)
    }

    public func deleteGroceryItem(for itemId: Int) async throws {
        try await client.delete(path: "v2/shopping/items/\(itemId)")
    }

    public func completeShoppingItem(for shoppingItemId: Int, _ request: CompleteShoppingItemRequest) async throws -> InventoryItem {
        try await client.post(
            InventoryItem.self,
            path: "v2/shopping/items/\(shoppingItemId)/complete",
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
