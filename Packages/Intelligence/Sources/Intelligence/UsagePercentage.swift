import FoundationModels
import Models
import Network
import SwiftUI

public enum GenerationState {
    case empty
    case loading
    case loaded
    case error
}

@Generable
struct UsagePrediction {
    @Guide(
        description: "A number between 0 and 100 representing the predicted percentage of the food item that will be consumed before disposal. Use 0 for items that will be completely wasted, 100 for items that will be fully consumed, and values in between for partial consumption.")
    let predictionPercentage: Int
}

@Observable
@MainActor
public final class UsageGenerator {
    public var percentagePrediction: Int?

    public var state: GenerationState = .empty

    let api = KeepFreshAPI()
    let model = SystemLanguageModel.default

    public init() {}

    public func generateUsagePrediction(
        predictions: InventoryPredictionsResponse,
        productName: String,
        categoryName: String,
        quantity: String? = nil,
        storageLocation: String? = nil,
        daysUntilExpiry: Int? = nil,
        status: String? = nil) async
    {
        guard model.availability == .available else {
            print("Unable to use Apple Intelligence")
            return
        }

        state = .loading

        do {
            let session = LanguageModelSession(instructions: """
            You are a food consumption prediction expert. Your task is to predict what percentage (0-100) of a food item will be consumed before disposal.

            PREDICTION RULES:
            1. Data Priority: Trust the strongest available signal in this order:
               - Product-specific history (most reliable)
               - Category history (if product has no history)
               - User baseline (fallback)

            2. Zero History Signal: If product or category shows 0% usage, this is a strong negative signal. Predict pessimistically near the user's baseline.

            3. Time Constraints: If the item has insufficient time before expiry compared to typical consumption speed, scale the prediction down proportionally.

            4. Low User Baseline: If user baseline is below 20%, the user tends to waste most food. Predict conservatively.

            5. Don't Average: Trust the strongest signal; don't average weak or missing data.

            OUTPUT EXAMPLES:
            Example 1:
            - Product: No history, Category: No history, User: 10% median
            - Analysis: No specific data, use user baseline
            - Prediction: 10%

            Example 2:
            - Product: No history, User: 28% average, 9.5% median
            - Analysis: Median is more reliable than average for typical behavior
            - Prediction: 15% (closer to median, accounting for pessimism)

            Example 3:
            - Product: 80% median, Typical: 10 days to consume, Days left: 3
            - Analysis: Strong product history but insufficient time (3/10 = 30%)
            - Prediction: 24% (time-limited: 30% of 80%)

            Example 4:
            - Product: No history, Category: 60% median (5+ items), User: 50%
            - Analysis: Category history is stronger signal than user baseline
            - Prediction: 60%
            """)

            let response = try await session.respond(
                to: buildPredictionPrompt(
                    predictions: predictions,
                    productName: productName,
                    categoryName: categoryName,
                    quantity: quantity,
                    storageLocation: storageLocation,
                    daysUntilExpiry: daysUntilExpiry,
                    status: status),
                generating: UsagePrediction.self,
                options: GenerationOptions(temperature: 0))

            percentagePrediction = response.content.predictionPercentage

            state = .loaded

        } catch {
            print("Usage prediction error: \(error)")
            state = .error
            percentagePrediction = calculateFallbackPrediction(predictions: predictions)
        }
    }

    // MARK: - Prompt Builder

    @PromptBuilder
    private func buildPredictionPrompt(
        predictions: InventoryPredictionsResponse,
        productName: String,
        categoryName: String,
        quantity: String?,
        storageLocation: String?,
        daysUntilExpiry: Int?,
        status: String?) -> Prompt
    {
        "FOOD ITEM:"
        buildProductContext(
            productName: productName,
            quantity: quantity,
            storageLocation: storageLocation,
            daysUntilExpiry: daysUntilExpiry,
            status: status)

        ""

        "HISTORICAL DATA:"
        buildProductHistory(predictions.productHistory)
        buildCategoryHistory(predictions.categoryHistory, categoryName: categoryName)
        buildUserBaseline(predictions.userBaseline)

        if let timeRatio = buildTimeRatioAnalysis(predictions: predictions, daysUntilExpiry: daysUntilExpiry) {
            ""
            "TIME ANALYSIS:"
            timeRatio
        }

        ""
        "Based on the above data and the prediction rules, predict what percentage (0-100) of this food item will be consumed before disposal:"
    }

    // MARK: - Helper Methods

    private func buildProductContext(
        productName: String,
        quantity: String?,
        storageLocation: String?,
        daysUntilExpiry: Int?,
        status: String?) -> String
    {
        var parts: [String] = [productName]

        if let quantity {
            parts.append(quantity)
        }

        if let storage = storageLocation {
            parts.append(storage)
        }

        if let status {
            parts.append(status)
        }

        if let days = daysUntilExpiry {
            parts.append("\(days) days until expiry")
        }

        return parts.joined(separator: ", ")
    }

    private func buildProductHistory(_ history: InventoryPredictionsResponse.ProductHistory) -> String {
        if history.purchaseCount == 0 {
            return "- Product History: No previous purchases of this specific item"
        }

        let usageList = history.usagePercentages.map { "\($0)%" }.joined(separator: ", ")

        var text = "- Product History: \(history.purchaseCount) purchases with usage: \(usageList)"

        if history.averageUsage == 0.0 {
            text += " (STRONG SIGNAL: This item was completely wasted every time before)"
        }

        if let medianUsage = history.medianUsage {
            text += ", median usage: \(String(format: "%.0f", medianUsage))%"
        } else {
            text += ", average usage: \(String(format: "%.0f", history.averageUsage))%"
        }

        if history.averageDaysToConsumeOrDiscarded > 0 {
            if let medianDays = history.medianDaysToConsumeOrDiscarded {
                text += ", typically consumed or discarded in \(String(format: "%.0f", medianDays)) days"
            } else {
                text += ", average days to consume or discard: \(String(format: "%.0f", history.averageDaysToConsumeOrDiscarded))"
            }
        }

        return text
    }

    private func buildCategoryHistory(_ history: InventoryPredictionsResponse.CategoryHistory, categoryName: String) -> String {
        if history.purchaseCount == 0 {
            return "- Category History (\(categoryName)): No items in this category have been tracked"
        }

        var text = "- Category History (\(categoryName)): "

        if history.averageUsage == 0.0 {
            text += "0% average usage (STRONG SIGNAL: All items in this category were wasted)"
        } else if let medianUsage = history.medianUsage {
            text += "median usage: \(String(format: "%.0f", medianUsage))%"
        } else {
            text += "average usage: \(String(format: "%.0f", history.averageUsage))%"
        }

        text += ", based on \(history.purchaseCount) items"

        if history.averageDaysToConsumeOrDiscarded > 0 {
            if let medianDays = history.medianDaysToConsumeOrDiscarded {
                text += ", typically \(String(format: "%.0f", medianDays)) days to consume or discard"
            } else {
                text += ", average \(String(format: "%.0f", history.averageDaysToConsumeOrDiscarded)) days to consume or discard"
            }
        }

        return text
    }

    private func buildUserBaseline(_ baseline: InventoryPredictionsResponse.UserBaseline) -> String {
        var text = "- User Baseline: "

        if let medianUsage = baseline.medianUsage {
            text += "median usage across all food: \(String(format: "%.0f", medianUsage))%"
            if medianUsage < 20 {
                text += " (WARNING: User typically wastes \(String(format: "%.0f", 100 - medianUsage))%+ of food - predict conservatively)"
            }
        } else {
            text += "average usage across all food: \(String(format: "%.0f", baseline.averageUsage))%"
        }

        text += ", based on \(baseline.totalItemsCount) total items tracked"

        if baseline.averageDaysToConsumeOrDiscarded > 0 {
            if let medianDays = baseline.medianDaysToConsumeOrDiscarded {
                text += ", typical time: \(String(format: "%.0f", medianDays)) days"
            } else {
                text += ", average time: \(String(format: "%.0f", baseline.averageDaysToConsumeOrDiscarded)) days"
            }
        }

        return text
    }

    private func buildTimeRatioAnalysis(
        predictions: InventoryPredictionsResponse,
        daysUntilExpiry: Int?) -> String?
    {
        guard let daysUntilExpiry, daysUntilExpiry > 0 else {
            return nil
        }

        let typicalDaysToConsume: Double? = if let medianDays = predictions.productHistory.medianDaysToConsumeOrDiscarded,
                                               predictions.productHistory.purchaseCount > 0
        {
            medianDays
        } else if predictions.productHistory.purchaseCount > 0 {
            predictions.productHistory.averageDaysToConsumeOrDiscarded
        } else if let medianDays = predictions.categoryHistory.medianDaysToConsumeOrDiscarded,
                  predictions.categoryHistory.purchaseCount >= 3
        {
            medianDays
        } else if predictions.categoryHistory.purchaseCount >= 3 {
            predictions.categoryHistory.averageDaysToConsumeOrDiscarded
        } else if let medianDays = predictions.userBaseline.medianDaysToConsumeOrDiscarded {
            medianDays
        } else {
            predictions.userBaseline.averageDaysToConsumeOrDiscarded
        }

        guard let consumeDays = typicalDaysToConsume, consumeDays > 0 else {
            return nil
        }

        let timeRatio = Double(daysUntilExpiry) / consumeDays
        let percentageOfTime = Int((timeRatio * 100).rounded())
        let maxRealistic = min(percentageOfTime, 100)

        var analysis =
            "Time available: \(daysUntilExpiry) days until expiry vs. typical consumption time: \(String(format: "%.0f", consumeDays)) days"

        if timeRatio < 1.0 {
            analysis += " (CRITICAL: Only \(percentageOfTime)% of typical time available - scale prediction down proportionally)"
        } else if timeRatio < 1.5 {
            analysis += " (WARNING: Limited time - may impact consumption)"
        }

        analysis += ". Maximum realistic consumption: ~\(maxRealistic)%"

        return analysis
    }

    private func calculateFallbackPrediction(predictions: InventoryPredictionsResponse) -> Int {
        if predictions.productHistory.purchaseCount > 0 {
            if let medianUsage = predictions.productHistory.medianUsage {
                return Int(medianUsage.rounded())
            }
            return Int(predictions.productHistory.averageUsage.rounded())
        }

        if predictions.categoryHistory.purchaseCount >= 3 {
            if let medianUsage = predictions.categoryHistory.medianUsage {
                return Int(medianUsage.rounded())
            }
            return Int(predictions.categoryHistory.averageUsage.rounded())
        }

        if let medianUsage = predictions.userBaseline.medianUsage {
            return Int(medianUsage.rounded())
        }
        return Int(predictions.userBaseline.averageUsage.rounded())
    }
}
