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

public struct ProductSearchItemSource: Codable, Hashable, Sendable {
    public init(id: Int, ref: String) {
        self.id = id
        self.ref = ref
    }

    public let id: Int
    public let ref: String
}

public struct ProductSearchItemResponse: Identifiable, Hashable, Codable, Sendable {
    public init(
        name: String,
        brand: Brand,
        category: ProductSearchItemCategory,
        amount: Double?,
        unit: String?,
        icon: String,
        source: ProductSearchItemSource)
    {
        self.name = name
        self.brand = brand
        self.category = category
        self.amount = amount
        self.unit = unit
        self.icon = icon
        self.source = source
    }

    public let name: String
    public let brand: Brand
    public let category: ProductSearchItemCategory
    public let amount: Double?
    public let unit: String?
    public let icon: String
    public let source: ProductSearchItemSource

    public var id: String {
        "\(source.ref)-\(brand)"
    }
}

public enum ExpiryType: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case UseBy = "Use By"
    case BestBefore = "Best Before"
    case LongLife = "Long Life"
}

public struct ProductSearchResponse: Codable, Sendable {
    public let products: [ProductSearchItemResponse]
}

// MARK: - Mock Data

public extension ProductSearchItemResponse {
    static var mock: ProductSearchItemResponse {
        mock(id: 1)
    }

    static func mock(id: Int) -> ProductSearchItemResponse {
        ProductSearchItemResponse(
            name: "Sample Product",
            brand: .tesco,
            category: ProductSearchItemCategory(
                id: id,
                name: "Sample Category",
                path: "Food > Sample",
                recommendedStorageLocation: .fridge),
            amount: 500,
            unit: "g",
            icon: "carrot.fill",
            source: ProductSearchItemSource(id: id, ref: "sample-\(id)"))
    }

    static func mocks(count: Int) -> [ProductSearchItemResponse] {
        (1...count).map { mock(id: $0) }
    }
}
