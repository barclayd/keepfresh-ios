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
        case .day: "d"
        case .week: "w"
        case .month: "m"
        case .year: "y"
        }
    }
}

public struct RelativeTime {
    public let amount: Int
    public let unit: TimeUnit
    public let totalDays: Int
    
    init(amount: Int, unit: TimeUnit, totalDays: Int) {
        self.amount = amount
        self.unit = unit
        self.totalDays = totalDays
    }
    
    public var abbreviated: String {
        "\(amount)\(unit.abbreviation)"
    }
    
    public var formatted: String {
        guard amount != 0 else { return "Today" }
        
        return "\(amount) \(unit.pluralised(for: amount))"
    }
    
    public var formattedUnit: String {
        "\(unit.pluralised(for: amount))"
    }
    
    public var formattedToExpiry: String {
        guard totalDays >= 0 else { return "\(unit.pluralised(for: amount).capitalized) expired" }
        
        return "\(unit.pluralised(for: amount).capitalized) to expiry"
    }
    
    public var formattedElapsedTime: String {
        guard amount != 0 else { return "Today" }
        
        return "\(formatted) ago"
    }
    
    public var totalDaysFormatted: String {
        guard totalDays > 7 else { return totalDays.formatted() }
        
        guard totalDays > 14 else { return "7+" }
        
        return abbreviated
    }
}

public func relativeTime(
    _ direction: TimeDirection,
    from date: Date,
    to referenceDate: Date = Date()) -> RelativeTime
{
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
    let days = dayComponents.day ?? 0
    
    let weekComponents = calendar.dateComponents([.weekOfYear], from: fromDate, to: toDate)
    let weeks = weekComponents.weekOfYear ?? 0
    
    let monthComponents = calendar.dateComponents([.month], from: fromDate, to: toDate)
    let months = monthComponents.month ?? 0
    
    let yearComponents = calendar.dateComponents([.year], from: fromDate, to: toDate)
    let years = yearComponents.year ?? 0
    
    let absDays = abs(days)
    let (value, unit): (Int, TimeUnit) = if absDays <= 7 {
        (days, .day)
    } else if absDays <= 28 {
        (weeks, .week)
    } else if abs(months) <= 12 {
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
