import Foundation

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

public enum TimeDirection {
    case since
    case until
}

public enum TimeUnit: String, CaseIterable {
    case day
    case week
    case month
    case year

    func pluralised(for amount: Int) -> String {
        let absAmount = abs(amount)
        return absAmount == 1 ? rawValue : "\(rawValue)s"
    }

    var abbreviation: String {
        switch self {
        case .day: return "d"
        case .week: return "w"
        case .month: return "m"
        case .year: return "y"
        }
    }
}

public struct RelativeTime {
    public let amount: Int
    public let unit: TimeUnit
    public let totalDays: Int

    init(amount: Int, unit: TimeUnit, totalDays: Int) {
        self.amount = abs(amount)
        self.unit = unit
        self.totalDays = abs(totalDays)
    }

    public var abbreviated: String {
        "\(amount)\(unit.abbreviation)"
    }

    public var formatted: String {
        "\(amount) \(unit.pluralised(for: amount))"
    }
}

public func relativeTime(
    _ direction: TimeDirection,
    from date: Date,
    to referenceDate: Date = Date()
) -> RelativeTime {
    let calendar = Calendar.current

    let normalizedDate = calendar.startOfDay(for: date)
    let normalizedReferenceDate = calendar.startOfDay(for: referenceDate)

    if calendar.isDate(normalizedDate, equalTo: normalizedReferenceDate, toGranularity: .day) {
        return RelativeTime(amount: 0, unit: .day, totalDays: 0)
    }

    let (fromDate, toDate) = switch direction {
    case .since:
        (normalizedDate, normalizedReferenceDate)
    case .until:
        (normalizedReferenceDate, normalizedDate)
    }

    let dayComponents = calendar.dateComponents([.day], from: fromDate, to: toDate)
    let days = abs(dayComponents.day ?? 0)

    let weekComponents = calendar.dateComponents([.weekOfYear], from: fromDate, to: toDate)
    let weeks = abs(weekComponents.weekOfYear ?? 0)

    let monthComponents = calendar.dateComponents([.month], from: fromDate, to: toDate)
    let months = abs(monthComponents.month ?? 0)

    let yearComponents = calendar.dateComponents([.year], from: fromDate, to: toDate)
    let years = abs(yearComponents.year ?? 0)

    let (value, unit): (Int, TimeUnit) = if days <= 7 {
        (days, .day)
    } else if days <= 28 {
        (weeks, .week)
    } else if months <= 12 {
        (months, .month)
    } else {
        (years, .year)
    }

    return RelativeTime(amount: value, unit: unit, totalDays: days)
}

public extension Date {
    func time(_ direction: TimeDirection, from referenceDate: Date = Date()) -> RelativeTime {
        relativeTime(direction, from: self, to: referenceDate)
    }

    var timeSince: RelativeTime {
        relativeTime(.since, from: self)
    }

    var timeUntil: RelativeTime {
        relativeTime(.until, from: self)
    }
}
