import DesignSystem
import SwiftUI

public enum ProductSearchItemStatus: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case opened
    case unopened
}

public struct ProductSearchItemCategory: Identifiable, Codable, Equatable, Hashable, Sendable {
    public init(id: Int, name: String, path: String, recommendedStorageLocation: StorageLocation) {
        self.id = id
        self.name = name
        self.path = path
        self.recommendedStorageLocation = recommendedStorageLocation
    }

    public let id: Int
    public let name: String
    public let path: String
    public let recommendedStorageLocation: StorageLocation
}

public struct ProductSearchResultItemResponse: Identifiable, Hashable, Codable, Sendable {
    public init(
        id: Int,
        name: String,
        brand: Brand,
        category: ProductSearchItemCategory,
        amount: Double?,
        unit: String?,
        icon: String)
    {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.amount = amount
        self.unit = unit
        self.icon = icon
    }

    public let id: Int
    public let name: String
    public let brand: Brand
    public let category: ProductSearchItemCategory
    public let amount: Double?
    public let unit: String?
    public let icon: String

    public var amountUnitFormatted: String? {
        guard let unit else { return nil }
        guard let amount else { return unit }

        let formattedUnit = unit == "l" ? "L" : unit

        return "\(String(format: "%.0f", amount))\(formattedUnit)"
    }
}

public enum ExpiryType: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case UseBy = "Use By"
    case BestBefore = "Best Before"
    case LongLife = "Long Life"
}

public struct ProductSearchPagination: Codable, Sendable {
    public let hasNext: Bool
}

public struct ProductSearchResponse: Codable, Sendable {
    public let pagination: ProductSearchPagination
    public let results: [ProductSearchResultItemResponse]
}

// MARK: - Mock Data

public extension ProductSearchResultItemResponse {
    static var mock: ProductSearchResultItemResponse {
        mock(id: 1)
    }

    static func mock(id: Int) -> ProductSearchResultItemResponse {
        ProductSearchResultItemResponse(
            id: id,
            name: "Sample Product",
            brand: .tesco,
            category: ProductSearchItemCategory(
                id: id,
                name: "Sample Category",
                path: "Food > Sample",
                recommendedStorageLocation: .fridge),
            amount: 500,
            unit: "g",
            icon: "carrot.fill")
    }

    static func mocks(count: Int) -> [ProductSearchResultItemResponse] {
        (1...count).map { mock(id: $0) }
    }
}
