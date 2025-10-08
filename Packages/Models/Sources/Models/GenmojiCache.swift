import Foundation
import SwiftData

@Model
public class GenmojiCache {
    @Attribute(.unique) public var name: String
    public var imageData: Data
    public var cachedAt: Date

    public init(name: String, imageData: Data, cachedAt: Date = Date()) {
        self.name = name
        self.imageData = imageData
        self.cachedAt = cachedAt
    }
}
