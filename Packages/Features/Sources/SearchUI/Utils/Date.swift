import Foundation
import Models

func addDaysToNow(_ days: Int) -> Date {
    let calendar: Calendar = .current
    return calendar.date(byAdding: .day, value: days, to: Date())!
}

func getExpiryDateForSelection(
    storage: StorageLocation,
    status: ProductSearchItemStatus,
    shelfLife: ShelfLifeInDays) -> Date?
{
    guard let expiryInDays = shelfLife[status][storage] else {
        return nil
    }

    return addDaysToNow(expiryInDays)
}

public extension Date {
    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: other, toGranularity: .day)
    }
}

public extension Date {
    var isoString: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
