import Foundation
import SwiftData

@Model
public class RecentSearch {
    public var imageURL: String?
    public var text: String
    public var recommendedStorageLocation: StorageLocation
    public var date: Date

    public init(imageURL: String?, text: String, recommendedStorageLocation: StorageLocation, date: Date) {
        self.imageURL = imageURL
        self.text = text
        self.recommendedStorageLocation = recommendedStorageLocation
        self.date = date
    }
}
