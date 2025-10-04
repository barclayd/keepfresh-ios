import Foundation
import SwiftData

@Model
public class RecentSearch {
    public var imageURL: String?
    public var text: String
    public var date: Date

    public init(imageURL: String?, text: String, date: Date) {
        self.imageURL = imageURL
        self.text = text
        self.date = date
    }
}
