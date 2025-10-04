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

    public func generateUsagePrediction(predictions: InventoryPredictionsResponse) async {
        guard model.availability == .available else {
            print("Unable to use Apple Intelligence")
            return
        }

        state = .loading

        do {
            let session = LanguageModelSession(instructions: """
            You are a food usage prediction system for a waste-tracking app. Your goal is to predict what percentage of a food item a user will consume before disposal.

            PREDICTION APPROACH:
            1. Prioritize individual item history (strongest signal)
            2. If no item history exists, use category patterns with quantity adjustments
            3. Apply contextual modifiers for events, dietary changes, or shopping patterns
            4. Express uncertainty when data is limited

            CONFIDENCE LEVELS:
            - High: 5+ purchases of exact item with low variance
            - Medium: 3-4 item purchases OR strong category data (10+ purchases)
            - Low: New item with limited or no category history

            OUTPUT RULES:
            - Percentage must be realistic (typically 50-100%)
            - Be conservative with low confidence predictions (70-75%)
            - Reasoning should reference specific data points from the input
            - Keep reasoning concise (1-2 sentences maximum)

            Return your prediction as a string, specifying the number only. e.g. 89
            """)

            let response = try await session.respond(to: """
            ITEM DETAILS:
            - Name: Chicken Thighs
            - Category: Fresh Chicken
            - Quantity: 1kg
            - Expires in: 3 days
            - Storage: Fridge
            - Store: Tesco

            HISTORICAL PERFORMANCE:
            - This item: Purchased 8 times. Usage percentages: [92%, 88%, 95%, 85%, 90%, 87%, 93%, 89%]. Average: 90% (std deviation: 3.2%). Last 3 purchases: 93%, 89%, 87%. Trend: stable.
            - Category average: Fresh Chicken purchased 24 times. Average usage: 83% (std deviation: 12%).
            - User's overall waste rate: 18% across all categories.

            Predict the usage percentage for this item.
            """)

            print("Model response: \(response)")

            percentagePrediction = Int(response.content) ?? 75

            state = .loaded

        } catch {
            state = .error
            return
        }

        state = .loaded
    }
}
