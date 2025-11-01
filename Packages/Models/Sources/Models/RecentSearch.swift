import Foundation
import SwiftData

@Model
public class RecentSearch {
    public var icon: String
    public var text: String
    public var recommendedStorageLocation: StorageLocation
    public var date: Date

    public init(icon: String, text: String, recommendedStorageLocation: StorageLocation, date: Date) {
        self.icon = icon
        self.text = text
        self.recommendedStorageLocation = recommendedStorageLocation
        self.date = date
    }
}
