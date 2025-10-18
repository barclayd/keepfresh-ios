import Foundation

public struct ProductUsageStatsResponse: Codable, Sendable {
    public init(medianDaysToOutcome: Double) {
        self.medianDaysToOutcome = medianDaysToOutcome
    }

    public let medianDaysToOutcome: Double
}
