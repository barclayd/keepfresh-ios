import DesignSystem
import Extensions
import SwiftUI

public enum InventoryItemStatus: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }

    case opened
    case discarded
    case consumed
    case unopened
}

public extension InventoryItemStatus {
    init(from productStatus: ProductSearchItemStatus) {
        switch productStatus {
        case .opened:
            self = .opened
        case .unopened:
            self = .unopened
        }
    }
}

public struct UpdateInventoryItemRequest: Codable, Sendable {
    public let status: InventoryItemStatus?
    public let storageLocation: StorageLocation?
    public let percentageRemaining: Int?

    public init(
        status: InventoryItemStatus? = nil,
        storageLocation: StorageLocation? = nil,
        percentageRemaining: Double?)
    {
        self.storageLocation = storageLocation
        self.status = status
        self.percentageRemaining = percentageRemaining.map { Int($0) }
    }
}

public struct AddInventoryItemRequest: Codable, Sendable {
    public let item: InventoryItem
    public let product: ProductData

    public init(item: InventoryItem, product: ProductData) {
        self.item = item
        self.product = product
    }

    public struct InventoryItem: Codable, Sendable {
        public let expiryDate: Date
        public let storageLocation: StorageLocation
        public let status: ProductSearchItemStatus
        public let expiryType: ExpiryType
        public let consumptionPrediction: Int?

        public init(
            expiryDate: Date,
            storageLocation: StorageLocation,
            status: ProductSearchItemStatus,
            expiryType: ExpiryType,
            consumptionPrediction: Int?)
        {
            self.expiryDate = expiryDate
            self.storageLocation = storageLocation
            self.status = status
            self.expiryType = expiryType
            self.consumptionPrediction = consumptionPrediction
        }
    }

    public struct ProductData: Codable, Sendable {
        public let name: String
        public let brand: String
        public let expiryType: ExpiryType
        public let storageLocation: StorageLocation
        public let barcode: String?
        public let unit: String?
        public let amount: Double?
        public let categoryId: Int
        public let sourceId: Int
        public let sourceRef: String

        public init(
            name: String,
            brand: String,
            expiryType: ExpiryType,
            storageLocation: StorageLocation,
            barcode: String?,
            unit: String?,
            amount: Double?,
            categoryId: Int,
            sourceId: Int,
            sourceRef: String)
        {
            self.name = name
            self.brand = brand
            self.expiryType = expiryType
            self.storageLocation = storageLocation
            self.barcode = barcode
            self.unit = unit
            self.amount = amount
            self.categoryId = categoryId
            self.sourceId = sourceId
            self.sourceRef = sourceRef
        }
    }
}

public struct AddInventoryItemResponse: Codable, Sendable {
    public let inventoryItemId: Int
}

public struct InventoryItemsResponse: Codable, Sendable {
    public let inventoryItems: [InventoryItem]
}

public struct TileColor {
    public let foreground: Color
    public let background: Color
    public let ai: Color
}

public enum ConsumptionUrgency: String, CaseIterable {
    case critical
    case attention
    case good

    public var tileColor: TileColor {
        switch self {
        case .critical:
            TileColor(foreground: .red800, background: .red200, ai: .yellow700)
        case .attention:
            TileColor(foreground: .yellow600, background: .yellow100, ai: .yellow600)
        case .good:
            TileColor(foreground: .green600, background: .green300, ai: .yellow500)
        }
    }
}

public struct InventoryItem: Codable, Sendable, Identifiable {
    public init(
        id: Int,
        createdAt: Date,
        updatedAt: Date,
        openedAt: Date? = nil,
        status: InventoryItemStatus,
        storageLocation: StorageLocation,
        consumptionPrediction: Int,
        expiryDate: Date,
        expiryType: ExpiryType,
        product: Product)
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.openedAt = openedAt
        self.status = status
        self.storageLocation = storageLocation
        self.consumptionPrediction = consumptionPrediction
        self.expiryDate = expiryDate
        self.expiryType = expiryType
        self.product = product
    }

    public let id: Int
    public let createdAt: Date
    public var updatedAt: Date
    public var openedAt: Date?
    public var status: InventoryItemStatus
    public var storageLocation: StorageLocation
    public let consumptionPrediction: Int
    public let expiryDate: Date
    public let expiryType: ExpiryType
    public let product: Product
}

public extension InventoryItem {
    init(
        from request: AddInventoryItemRequest,
        category: ProductSearchItemCategory,
        id: Int,
        productId: Int,
        imageURL: String?,
        createdAt: Date = Date())
    {
        self.id = id
        self.createdAt = createdAt
        updatedAt = createdAt
        openedAt = nil
        status = InventoryItemStatus(from: request.item.status)
        storageLocation = request.item.storageLocation
        expiryDate = request.item.expiryDate
        expiryType = request.item.expiryType
        product = Product(
            id: productId,
            name: request.product.name,
            unit: request.product.unit,
            brand: Brand(from: request.product.brand),
            amount: request.product.amount,
            imageUrl: imageURL,
            category: CategoryDetails(name: category.name, pathDisplay: category.path))
        consumptionPrediction = 100
    }
}

public extension InventoryItem {
    var consumptionUrgency: ConsumptionUrgency {
        let days = expiryDate.timeUntil.totalDays
        let prediction = consumptionPrediction

        if days <= 0 { return .critical }
        if days == 1, prediction < 60 { return .critical }

        if days <= 7 {
            if prediction < 35 { return .critical }
            if prediction < 65 || days <= 3 { return .attention }
            return .good
        }

        if prediction < 30 { return .attention }
        return .good
    }
}

public struct Product: Codable, Sendable {
    public init(
        id: Int,
        name: String,
        unit: String?,
        brand: Brand,
        amount: Double?,
        imageUrl: String? = nil,
        category: CategoryDetails)
    {
        self.id = id
        self.name = name
        self.unit = unit
        self.brand = brand
        self.amount = amount
        self.imageUrl = imageUrl
        self.category = category
    }

    public let id: Int
    public let name: String
    public let unit: String?
    public let brand: Brand
    public let amount: Double?
    public let imageUrl: String?
    public let category: CategoryDetails

    public var unitFormatted: String? {
        guard let unit else { return nil }

        switch unit {
        case "l":
            return unit.uppercased(with: .current)
        default:
            return unit
        }
    }
}

public struct CategoryDetails: Codable, Sendable {
    public init(icon: String? = nil, name: String, imageUrl: String? = nil, pathDisplay: String) {
        self.icon = icon
        self.name = name
        self.imageUrl = imageUrl
        self.pathDisplay = pathDisplay
    }

    public let icon: String?
    public let name: String
    public let imageUrl: String?
    public let pathDisplay: String
}

public enum Brand: Codable, Equatable, Hashable, Sendable {
    case tesco
    case sainsburys
    case unknown(String)

    private static let brandData: [(Brand, String, Color)] = [
        (.tesco, "Tesco", .brandTesco),
        (.sainsburys, "Sainsbury's", .brandSainsburys),
    ]

    private static let knownBrands: [String: Brand] = Dictionary(uniqueKeysWithValues: brandData.map { ($0.1, $0.0) })

    private static let brandColors: [Brand: Color] = Dictionary(uniqueKeysWithValues: brandData.map { ($0.0, $0.2) })

    private static let brandNames: [Brand: String] = Dictionary(uniqueKeysWithValues: brandData.map { ($0.0, $0.1) })

    public var name: String {
        Self.brandNames[self] ?? {
            if case let .unknown(name) = self { return name }
            return "Unknown"
        }()
    }

    public var color: Color {
        Self.brandColors[self] ?? .gray
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let brandString = try container.decode(String.self)
        self = Self.knownBrands[brandString] ?? .unknown(brandString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

public extension Brand {
    init(from brandString: String) {
        self = Self.knownBrands[brandString] ?? .unknown(brandString)
    }
}

// MARK: - Inventory Preview

public struct InventoryPreviewRequest: Codable, Sendable {
    public let product: PreviewProduct

    public init(product: PreviewProduct) {
        self.product = product
    }

    public struct PreviewProduct: Codable, Sendable {
        public let name: String
        public let brand: String
        public let barcode: String?
        public let unit: String?
        public let amount: Double?
        public let categoryId: Int
        public let sourceId: Int
        public let sourceRef: String

        public init(
            name: String,
            brand: String,
            barcode: String? = nil,
            unit: String? = nil,
            amount: Double? = nil,
            categoryId: Int,
            sourceId: Int,
            sourceRef: String)
        {
            self.name = name
            self.brand = brand
            self.barcode = barcode
            self.unit = unit?.lowercased()
            self.amount = amount
            self.categoryId = categoryId
            self.sourceId = sourceId
            self.sourceRef = sourceRef
        }
    }
}

public struct InventoryPredictionsResponse: Codable, Sendable {
    public let productHistory: ProductHistory
    public let categoryHistory: CategoryHistory
    public let userBaseline: UserBaseline

    public struct ProductHistory: Codable, Sendable {
        public let purchaseCount: Int
        public let consumedCount: Int
        public let usagePercentages: [Int]
        public let averageUsage: Double
        public let medianUsage: Double?
        public let standardDeviation: Double
        public let averageDaysToConsumeOrDiscarded: Double
        public let medianDaysToConsumeOrDiscarded: Double?
    }

    public struct CategoryHistory: Codable, Sendable {
        public let purchaseCount: Int
        public let averageUsage: Double
        public let medianUsage: Double?
        public let standardDeviation: Double
        public let averageDaysToConsumeOrDiscarded: Double
        public let medianDaysToConsumeOrDiscarded: Double?
    }

    public struct UserBaseline: Codable, Sendable {
        public let averageUsage: Double
        public let medianUsage: Double?
        public let totalItemsCount: Int
        public let averageDaysToConsumeOrDiscarded: Double
        public let medianDaysToConsumeOrDiscarded: Double?
    }
}

public struct InventoryPreviewAndSuggestionsResponse: Codable, Sendable {
    public let productId: Int
    public let predictions: InventoryPredictionsResponse
    public let suggestions: InventorySuggestionsResponse
}

// MARK: - Mock Data

public extension InventoryItem {
    static var mock: InventoryItem {
        mock(id: 1)
    }

    static func mock(id: Int) -> InventoryItem {
        InventoryItem(
            id: id,
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: Date(),
            openedAt: nil,
            status: .unopened,
            storageLocation: .fridge,
            consumptionPrediction: 85,
            expiryDate: Date().addingTimeInterval(86400 * 5),
            expiryType: .BestBefore,
            product: Product(
                id: id,
                name: "Sample Product",
                unit: "g",
                brand: .tesco,
                amount: 500,
                imageUrl: "https://keep-fresh-images.s3.eu-west-2.amazonaws.com/chicken-leg.png",
                category: CategoryDetails(
                    icon: "carrot.fill",
                    name: "Vegetables",
                    imageUrl: "https://keep-fresh-images.s3.eu-west-2.amazonaws.com/chicken-leg.png",
                    pathDisplay: "Food > Vegetables")))
    }

    static func mocks(count: Int) -> [InventoryItem] {
        (1...count).map { mock(id: $0) }
    }
}
