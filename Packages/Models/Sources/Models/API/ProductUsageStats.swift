import Foundation

public struct ProductUsageStatsResponse: Codable, Sendable {
    public let product: ProductStats
    public let category: CategoryStats

    public struct ProductStats: Codable, Sendable {
        public let medianDaysToOutcome: Double
        public let medianUsage: Double
    }

    public struct CategoryStats: Codable, Sendable {
        public let medianUsage: Double
    }
}
