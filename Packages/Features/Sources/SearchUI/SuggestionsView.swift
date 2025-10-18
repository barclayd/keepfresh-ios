import Extensions
import Models
import SwiftUI

enum HistoryType {
    case product
    case category
    case user
}

enum Sentiment {
    case positive
    case negative
    case neutral
}

func getStorageLocation(storageLocation: StorageLocation?) -> String {
    guard let storageLocation else {
        return "Consider alternatives for better usage"
    }

    guard storageLocation == .freezer else {
        return "Consider storing in the \(storageLocation.rawValue) to extend expiry"
    }

    return "Consider freezing early to extend expiry"
}

@ViewBuilder
func historyView(
    type: HistoryType,
    sentiment: Sentiment,
    storageLocation: StorageLocation,
    suggestedStorageLocation: StorageLocation?,
    itemName: String,
    categoryName: String,
    medianProductUsage: Double,
    medianCategoryUsage: Double,
    medianTotalUsage: Double) -> some View
{
    let countryName = Locale.current.region?.identifier ?? "UK"

    let storageSuggestion = getStorageLocation(storageLocation: suggestedStorageLocation)

    switch (type, sentiment) {
    case (.product, .positive):
        Suggestion(
            icon: "checkmark.seal.fill",
            iconColor: .green600,
            text: "Your food usage for \(itemName) is very high at \(String(format: "%.0f", medianProductUsage))%",
            textColor: storageLocation.infoColor)
    case (.product, .negative):
        Suggestion(
            icon: "exclamationmark.triangle.fill",
            iconColor: .red800,
            text: "Your usage for \(itemName) is very low at \(String(format: "%.0f", medianProductUsage))%",
            textColor: storageLocation.infoColor)
    case (.product, .neutral):
        Suggestion(
            icon: "chart.xyaxis.line",
            iconColor: .yellow700,
            text: "Your usage for \(itemName) matches the average rate at \(String(format: "%.0f", medianProductUsage))%",
            textColor: storageLocation.infoColor)
    case (.category, .positive):
        Suggestion(
            icon: "basket.fill",
            iconColor: .green600,
            text: "Great choice, your usage of \(categoryName) is excellent at \(String(format: "%.0f", medianCategoryUsage))%",
            textColor: storageLocation.infoColor)
    case (.category, .negative):
        Suggestion(
            icon: "cart.fill.badge.minus",
            iconColor: .red800,
            text: "Your usage of \(categoryName) is below average at \(String(format: "%.0f", medianCategoryUsage))%.\(storageSuggestion)",
            textColor: storageLocation.infoColor)
    case (.category, .neutral):
        Suggestion(
            icon: "cart.fill.badge.questionmark",
            iconColor: .yellow700,
            text: "This might be a good option, food usage for \(categoryName) is average at \(String(format: "%.0f", medianCategoryUsage))%. \(storageSuggestion)",
            textColor: storageLocation.infoColor)
    case (.user, .positive):
        Suggestion(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: .green600,
            text: "Your overall usage is superb at \(String(format: "%.0f", medianTotalUsage))%, above average for \(countryName)",
            textColor: storageLocation.infoColor)
    case (.user, .negative):
        Suggestion(
            icon: "chart.line.downtrend.xyaxis",
            iconColor: .red800,
            text: "Your overall usage is below average for \(countryName) at \(String(format: "%.0f", medianTotalUsage))%",
            textColor: storageLocation.infoColor)
    case (.user, .neutral):
        Suggestion(
            icon: "chart.xyaxis.line",
            iconColor: .yellow700,
            text: "Your overall usage is average for \(countryName) at \(String(format: "%.0f", medianTotalUsage))%",
            textColor: storageLocation.infoColor)
    }
}

public struct Suggestion: View {
    let icon: String
    let iconColor: Color
    let text: String
    let textColor: Color

    public var body: some View {
        GridRow {
            Image(systemName: icon).fontWeight(.bold)
                .foregroundStyle(iconColor)
                .font(.system(size: 32))
            Text(text)
                .font(.callout)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2...2)

            Spacer()
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
            if predictions.productHistory.consumedCount > 0 {
                Suggestion(
                    icon: "calendar.badge",
                    iconColor: .green600,
                    text: "\(itemName) will likely last you \(getRelativeDateInFuture(medianNumberOfDays: predictions.productHistory.medianDaysToConsumeOrDiscarded ?? predictions.productHistory.averageDaysToConsumeOrDiscarded))",
                    textColor: storageLocation.infoColor)
            }

            if predictions.productHistory.purchaseCount == 0, predictions.categoryHistory.purchaseCount == 0 {
                Suggestion(
                    icon: "book.fill",
                    iconColor: .yellow700,
                    text: "You haven’t added \(categoryName) before",
                    textColor: storageLocation.infoColor)

                if suggestions.expiryType == .UseBy {
                    Suggestion(
                        icon: "hourglass.bottomhalf.filled",
                        iconColor: .red800,
                        text: "\(itemName) spoils quickly after the expiry date",
                        textColor: storageLocation.infoColor)
                }
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

            if predictions.productHistory.consumedCount > 0 {
                historyView(
                    type: .product,
                    sentiment: getSentimentForUsage(
                        usage: predictions.productHistory.medianUsage ?? predictions.productHistory
                            .averageUsage),
                    storageLocation: storageLocation,
                    suggestedStorageLocation: storageLocationToExtendExpiry,
                    itemName: itemName,
                    categoryName: categoryName,
                    medianProductUsage: predictions.productHistory.medianUsage ?? predictions.productHistory.averageUsage,
                    medianCategoryUsage: predictions.categoryHistory.medianUsage ?? predictions.categoryHistory.averageUsage,
                    medianTotalUsage: predictions.userBaseline.medianUsage ?? predictions.userBaseline.averageUsage)
            }

            if predictions.categoryHistory.purchaseCount > 0 {
                historyView(
                    type: .category,
                    sentiment: getSentimentForUsage(
                        usage: predictions.categoryHistory.medianUsage ?? predictions.categoryHistory
                            .averageUsage),
                    storageLocation: storageLocation,
                    suggestedStorageLocation: storageLocationToExtendExpiry,
                    itemName: itemName,
                    categoryName: categoryName,
                    medianProductUsage: predictions.productHistory.medianUsage ?? predictions.productHistory.averageUsage,
                    medianCategoryUsage: predictions.categoryHistory.medianUsage ?? predictions.categoryHistory.averageUsage,
                    medianTotalUsage: predictions.userBaseline.medianUsage ?? predictions.userBaseline.averageUsage)
            } else {
                historyView(
                    type: .user,
                    sentiment: getSentimentForUsage(usage: predictions.userBaseline.medianUsage ?? predictions.userBaseline.averageUsage),
                    storageLocation: storageLocation,
                    suggestedStorageLocation: storageLocationToExtendExpiry,
                    itemName: itemName,
                    categoryName: categoryName,
                    medianProductUsage: predictions.productHistory.medianUsage ?? predictions.productHistory.averageUsage,
                    medianCategoryUsage: predictions.categoryHistory.medianUsage ?? predictions.categoryHistory.averageUsage,
                    medianTotalUsage: predictions.userBaseline.medianUsage ?? predictions.userBaseline.averageUsage)
            }

        }.padding(.vertical, 5).padding(.bottom, 10).padding(.horizontal, 20)
    }
}
