import Foundation
import Models

func addDaysToNow(_ days: Int) -> Date {
    let calendar: Calendar = .current
    return calendar.date(byAdding: .day, value: days, to: Date())!
}

func getExpiryDateForSelection(storage: InventoryStore, status: ProductSearchItemStatus, shelfLife: ShelfLifeInDays) -> Date? {
    guard let expiryInDays = shelfLife[status][storage] else {
        return nil
    }

    return addDaysToNow(expiryInDays)
}
