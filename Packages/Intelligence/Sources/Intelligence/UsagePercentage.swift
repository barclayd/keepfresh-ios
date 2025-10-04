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
            You predict what percentage (0-100) of a food item will be consumed before disposal.

            CORE RULES:
            • 0% history = predict pessimistically near user baseline (strong negative signal)
            • Time constraint: if insufficient time to consume based on typical speed, scale down proportionally
            • Data priority: product history > category history > user baseline
            • Low user baseline (<20%) = user wastes most food, predict conservatively
            • Trust strongest available signal, don't average weak data

            EXAMPLES:
            • Product 0%, Category 0%, User 10% median → Predict ~10%
            • Product 0%, User 28% average, 9.5% median → Predict ~15% (closer to median)
            • Product 80%, Typical 10 days, Only 3 days left → Predict ~24% (time-limited: 3/10 × 80)
            • No product data, Category 60%, User 50% → Predict ~60% (category is stronger)

            OUTPUT:
            Return ONLY an integer 0-100. No text, no %, no explanation.
            """)

            let productHistoryText = buildProductHistoryText(predictions.productHistory)
            let categoryHistoryText = buildCategoryHistoryText(predictions.categoryHistory, categoryName: categoryName)
            let userBaselineText = buildUserBaselineText(predictions.userBaseline)
            let productContextText = buildProductContextText(
                productName: productName,
                quantity: quantity,
                storageLocation: storageLocation,
                daysUntilExpiry: daysUntilExpiry,
                status: status)
            let timeRatioText = buildTimeRatioAnalysis(predictions: predictions, daysUntilExpiry: daysUntilExpiry)

            var prompt = """
            Item: \(productContextText)
            \(productHistoryText)
            \(categoryHistoryText)
            \(userBaselineText)
            """

            if let timeRatio = timeRatioText {
                prompt += "\n\(timeRatio)"
            }

            prompt += "\n\nPredict 0-100:"

            let response = try await session.respond(to: prompt, options: GenerationOptions(temperature: 0))

            if let prediction = Int(response.content.trimmingCharacters(in: .whitespacesAndNewlines)) {
                percentagePrediction = min(max(prediction, 0), 100)
            } else {
                percentagePrediction = calculateFallbackPrediction(predictions: predictions)
            }

            state = .loaded

        } catch {
            print("Usage prediction error: \(error)")
            state = .error
            percentagePrediction = calculateFallbackPrediction(predictions: predictions)
        }
    }

    // MARK: - Helper Methods

    private func buildProductHistoryText(_ history: InventoryPredictionsResponse.ProductHistory) -> String {
        if history.purchaseCount == 0 {
            return "Product: No history"
        }

        let usageList = history.usagePercentages.map { "\($0)%" }.joined(separator: ", ")

        var text = "Product: Used \(usageList)"

        if history.averageUsage == 0.0 {
            text += " (0% = completely wasted before)"
        }

        if let medianUsage = history.medianUsage {
            text += ", median \(String(format: "%.0f", medianUsage))%"
        } else {
            text += ", avg \(String(format: "%.0f", history.averageUsage))%"
        }

        if history.averageDaysToConsumeOrDiscarded > 0 {
            if let medianDays = history.medianDaysToConsumeOrDiscarded {
                text += ", typically \(String(format: "%.0f", medianDays)) days to consume"
            } else {
                text += ", avg \(String(format: "%.0f", history.averageDaysToConsumeOrDiscarded)) days to consume"
            }
        }

        return text
    }

    private func buildCategoryHistoryText(_ history: InventoryPredictionsResponse.CategoryHistory, categoryName: String) -> String {
        if history.purchaseCount == 0 {
            return "Category: No \(categoryName) history"
        }

        var text = "Category: \(categoryName) "

        if history.averageUsage == 0.0 {
            text += "0% avg (all wasted)"
        } else if let medianUsage = history.medianUsage {
            text += "\(String(format: "%.0f", medianUsage))% median"
        } else {
            text += "\(String(format: "%.0f", history.averageUsage))% avg"
        }

        text += ", \(history.purchaseCount) items"

        if history.averageDaysToConsumeOrDiscarded > 0 {
            if let medianDays = history.medianDaysToConsumeOrDiscarded {
                text += ", typically \(String(format: "%.0f", medianDays)) days"
            } else {
                text += ", avg \(String(format: "%.0f", history.averageDaysToConsumeOrDiscarded)) days"
            }
        }

        return text
    }

    private func buildUserBaselineText(_ baseline: InventoryPredictionsResponse.UserBaseline) -> String {
        var text = "User baseline: "

        if let medianUsage = baseline.medianUsage {
            text += "\(String(format: "%.0f", medianUsage))% median"
            if medianUsage < 20 {
                text += " (wastes \(String(format: "%.0f", 100 - medianUsage))%+)"
            }
        } else {
            text += "\(String(format: "%.0f", baseline.averageUsage))% avg"
        }

        text += ", \(baseline.totalItemsCount) items tracked"

        if baseline.averageDaysToConsumeOrDiscarded > 0 {
            if let medianDays = baseline.medianDaysToConsumeOrDiscarded {
                text += ", typically \(String(format: "%.0f", medianDays)) days"
            } else {
                text += ", avg \(String(format: "%.0f", baseline.averageDaysToConsumeOrDiscarded)) days"
            }
        }

        return text
    }

    private func buildProductContextText(
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
            parts.append("\(days) days left")
        }

        return parts.joined(separator: ", ")
    }

    private func buildTimeRatioAnalysis(
        predictions: InventoryPredictionsResponse,
        daysUntilExpiry: Int?) -> String?
    {
        guard let daysUntilExpiry, daysUntilExpiry > 0 else {
            return nil
        }

        // Prefer median over average for typical behavior
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
        let maxRealistic = min(Int((timeRatio * 100).rounded()), 100)

        return "Time: \(daysUntilExpiry) days vs typical \(String(format: "%.0f", consumeDays)) days = max ~\(maxRealistic)% realistic"
    }

    private func calculateFallbackPrediction(predictions: InventoryPredictionsResponse) -> Int {
        // Prefer median over average for more realistic fallback
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

        // Use median baseline for more realistic prediction of typical behavior
        if let medianUsage = predictions.userBaseline.medianUsage {
            return Int(medianUsage.rounded())
        }
        return Int(predictions.userBaseline.averageUsage.rounded())
    }
}
