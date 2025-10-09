import Foundation

public struct GenmojiUploadRequest: Codable, Sendable {
    public let name: String
    public let contentIdentifier: String
    public let contentDescription: String
    public let imageContent: Data
    public let contentType: String

    public init(
        name: String,
        contentIdentifier: String,
        contentDescription: String,
        imageContent: Data,
        contentType: String)
    {
        self.name = name
        self.contentIdentifier = contentIdentifier
        self.contentDescription = contentDescription
        self.imageContent = imageContent
        self.contentType = contentType
    }
}

public struct GenmojiUploadResponse: Codable, Sendable {
    public init() {}
}

public struct GenmojiGetResponse: Codable, Sendable {
    public let contentDescription: String
    public let imageContent: String
    public let contentType: String
    public let contentIdentifier: String

    public var imageContentData: Data? {
        Data(base64Encoded: imageContent)
    }

    public init(
        contentDescription: String,
        imageContent: String,
        contentType: String,
        contentIdentifier: String)
    {
        self.contentDescription = contentDescription
        self.imageContent = imageContent
        self.contentType = contentType
        self.contentIdentifier = contentIdentifier
    }
}
