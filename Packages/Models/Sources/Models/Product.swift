import DesignSystem
import SwiftUI

public enum ProductSearchItemStatus: String, Codable, Identifiable, CaseIterable {
  public var id: Self { self }

  case opened
  case unopened
}

public struct ProductSearchItemCategory: Identifiable, Codable, Equatable, Hashable, Sendable {
  public init(id: Int, name: String, path: String) {
    self.id = id
    self.name = name
    self.path = path
  }

  public let id: Int
  public let name: String
  public let path: String
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
    brand: String,
    category: ProductSearchItemCategory,
    amount: Double?,
    unit: String?,
    icon: String?,
    imageURL: String?,
    source: ProductSearchItemSource
  ) {
    self.name = name
    self.brand = brand
    self.category = category
    self.amount = amount
    self.unit = unit
    self.icon = icon
    self.imageURL = imageURL
    self.source = source
  }

  public let name: String
  public let brand: String
  public let category: ProductSearchItemCategory
  public let amount: Double?
  public let unit: String?
  public let icon: String?
  public let imageURL: String?
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
