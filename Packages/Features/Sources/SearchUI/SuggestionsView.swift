import Extensions
import Models
import SharedUI
import SwiftUI

enum Sentiment {
    case positive
    case negative
    case neutral
}

enum UsageHistorySuggestion {
    case product(
        usage: Double,
        sentiment: Sentiment,
        itemName: String,
        storageLocation: StorageLocation,
        suggestedStorageLocation: StorageLocation?)

    case category(
        usage: Double,
        sentiment: Sentiment,
        categoryName: String,
        storageLocation: StorageLocation,
        suggestedStorageLocation: StorageLocation?)

    case user(
        usage: Double,
        sentiment: Sentiment,
        storageLocation: StorageLocation)
}

func getStorageSuggestion(for storageLocation: StorageLocation?) -> String {
    guard let storageLocation else {
        return "Consider alternatives for better usage"
    }

    switch storageLocation {
    case .freezer:
        return "Consider freezing early to extend expiry"
    case .fridge, .pantry:
        return "Consider storing in the \(storageLocation.rawValue) to extend expiry"
    }
}

@ViewBuilder
@MainActor
func usageHistoryView(suggestion: UsageHistorySuggestion) -> some View {
    let countryName = Locale.current.region?.identifier ?? "UK"

    switch suggestion {
    case let .product(usage, sentiment, itemName, storageLocation, _):
        switch sentiment {
        case .positive:
            Suggestion(
                icon: "checkmark.seal.fill",
                iconColor: .green600,
                text: "Your food usage for \(itemName) is very high at \(String(format: "%.0f", usage))%",
                textColor: storageLocation.infoColor)
        case .negative:
            Suggestion(
                icon: "exclamationmark.triangle.fill",
                iconColor: .red800,
                text: "Your usage for \(itemName) is very low at \(String(format: "%.0f", usage))%",
                textColor: storageLocation.infoColor)
        case .neutral:
            Suggestion(
                icon: "chart.xyaxis.line",
                iconColor: .yellow700,
                text: "Your usage for \(itemName) matches the average rate at \(String(format: "%.0f", usage))%",
                textColor: storageLocation.infoColor)
        }

    case let .category(usage, sentiment, categoryName, storageLocation, suggestedStorageLocation):
        let storageSuggestion = getStorageSuggestion(for: suggestedStorageLocation)

        switch sentiment {
        case .positive:
            Suggestion(
                icon: "basket.fill",
                iconColor: .green600,
                text: "Great choice, your usage of \(categoryName) is excellent at \(String(format: "%.0f", usage))%",
                textColor: storageLocation.infoColor)
        case .negative:
            Suggestion(
                icon: "cart.fill.badge.minus",
                iconColor: .red800,
                text: "Your usage of \(categoryName) is below average at \(String(format: "%.0f", usage))%. \(storageSuggestion)",
                textColor: storageLocation.infoColor)
        case .neutral:
            Suggestion(
                icon: "cart.fill.badge.questionmark",
                iconColor: .yellow700,
                text: "This might be a good option, food usage for \(categoryName) is average at \(String(format: "%.0f", usage))%. \(storageSuggestion)",
                textColor: storageLocation.infoColor)
        }

    case let .user(usage, sentiment, storageLocation):
        switch sentiment {
        case .positive:
            Suggestion(
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .green600,
                text: "Your overall usage is superb at \(String(format: "%.0f", usage))%, above average for \(countryName)",
                textColor: storageLocation.infoColor)
        case .negative:
            Suggestion(
                icon: "chart.line.downtrend.xyaxis",
                iconColor: .red800,
                text: "Your overall usage is below average for \(countryName) at \(String(format: "%.0f", usage))%",
                textColor: storageLocation.infoColor)
        case .neutral:
            Suggestion(
                icon: "chart.xyaxis.line",
                iconColor: .yellow700,
                text: "Your overall usage is average for \(countryName) at \(String(format: "%.0f", usage))%",
                textColor: storageLocation.infoColor)
        }
    }
}

func getSentimentForUsage(usage: Double) -> Sentiment {
    switch usage {
    case 0...60:
        .negative
    case 60...75:
        .neutral
    case 75...100:
        .positive
    default:
        .neutral
    }
}

func getRelativeDateInFuture(medianNumberOfDays: Double) -> String {
    let date = Calendar.current.date(byAdding: .day, value: Int(medianNumberOfDays), to: Date())!

    if date.timeUntil.totalDays == 0 {
        return "until today"
    }

    if date.timeUntil.totalDays == 1 {
        return "until tomorrow"
    }

    if date.timeUntil.totalDays < 8 {
        return "until \(date.formatted(.dateTime.weekday(.wide)))"
    }

    return "for \(date.timeUntil.formatted)"
}

func getRelativeShortenedExpiry(numberOfDays: Int) -> String {
    let date = Calendar.current.date(byAdding: .day, value: Int(numberOfDays), to: Date())!

    return date.timeUntil.formatted
}

public struct SuggestionsView: View {
    let storageLocation: StorageLocation

    let predictions: InventoryPredictionsResponse
    let suggestions: InventorySuggestionsResponse

    let itemName: String
    let categoryName: String

    var storageLocationToExtendExpiry: StorageLocation? {
        guard suggestions.recommendedStorageLocation != .freezer else { return nil }

        let pantryShelfLife = suggestions.shelfLifeInDays.unopened.pantry
        let fridgeShelfLife = suggestions.shelfLifeInDays.unopened.fridge
        let freezerShelfLife = suggestions.shelfLifeInDays.unopened.freezer

        if suggestions.recommendedStorageLocation == .pantry,
           let pantryShelfLife,
           let fridgeShelfLife,
           fridgeShelfLife > pantryShelfLife
        {
            return .fridge
        }

        if suggestions.recommendedStorageLocation == .pantry,
           let pantryShelfLife,
           let freezerShelfLife,
           freezerShelfLife > pantryShelfLife
        {
            return .freezer
        }

        if suggestions.recommendedStorageLocation == .fridge,
           let fridgeShelfLife,
           let freezerShelfLife,
           freezerShelfLife > fridgeShelfLife
        {
            return .freezer
        }

        return nil
    }

    public var body: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 20) {
            if let medianNumberOfDays = predictions.productHistory.medianDaysToConsumeOrDiscarded {
                Suggestion(
                    icon: "calendar.badge",
                    iconColor: .green600,
                    text: "\(itemName) will likely last you \(getRelativeDateInFuture(medianNumberOfDays: medianNumberOfDays))",
                    textColor: storageLocation.infoColor)
            }

            if predictions.productHistory.purchaseCount == 0, predictions.categoryHistory.purchaseCount == 0 {
                Suggestion(
                    icon: "book.fill",
                    iconColor: .yellow700,
                    text: "You haven’t added \(categoryName) before. Usage will make predictions smarter",
                    textColor: storageLocation.infoColor)
            }

            let differenceInExpiryAfterOpening = (suggestions.shelfLifeInDays.unopened[suggestions.recommendedStorageLocation] ?? 0) -
                (suggestions.shelfLifeInDays.opened[suggestions.recommendedStorageLocation] ?? 0)

            if differenceInExpiryAfterOpening > 3, suggestions.recommendedStorageLocation != .freezer {
                Suggestion(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .yellow700,
                    text: "Shelf life shortens by \(getRelativeShortenedExpiry(numberOfDays: differenceInExpiryAfterOpening)) after opening. This item \(suggestions.shelfLifeInDays.opened.freezer != nil || suggestions.shelfLifeInDays.unopened.freezer != nil ? "is" : "isn't") suitable for freezing.",
                    textColor: storageLocation.infoColor)
            }

            if let productUsage = predictions.productHistory.medianUsage ?? predictions.productHistory.averageUsage {
                usageHistoryView(
                    suggestion: .product(
                        usage: productUsage,
                        sentiment: getSentimentForUsage(usage: productUsage),
                        itemName: itemName,
                        storageLocation: storageLocation,
                        suggestedStorageLocation: storageLocationToExtendExpiry)
                )
            }

            if let categoryUsage = predictions.categoryHistory.medianUsage ?? predictions.categoryHistory.averageUsage {
                usageHistoryView(
                    suggestion: .category(
                        usage: categoryUsage,
                        sentiment: getSentimentForUsage(usage: categoryUsage),
                        categoryName: categoryName,
                        storageLocation: storageLocation,
                        suggestedStorageLocation: storageLocationToExtendExpiry)
                )
            } else if let userUsage = predictions.userBaseline.medianUsage ?? predictions.userBaseline.averageUsage {
                usageHistoryView(
                    suggestion: .user(
                        usage: userUsage,
                        sentiment: getSentimentForUsage(usage: userUsage),
                        storageLocation: storageLocation)
                )
            }

            if suggestions.expiryType == .UseBy {
                Suggestion(
                    icon: "hourglass.bottomhalf.filled",
                    iconColor: .red800,
                    text: "\(itemName) spoils quickly after the expiry date",
                    textColor: storageLocation.infoColor)
            }

        }.padding(.vertical, 5).padding(.bottom, 10).padding(.horizontal, 20)
    }
}
