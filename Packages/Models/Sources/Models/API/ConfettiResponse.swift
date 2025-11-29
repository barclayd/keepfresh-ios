import Foundation

public struct ConfettiGenmojiItem: Codable, Sendable {
    public let name: String
    public let genmoji: ConfettiGenmoji
}

public struct ConfettiGenmoji: Codable, Sendable {
    public let name: String
    public let contentIdentifier: String
    public let contentDescription: String
    public let imageContent: String
    public let contentType: String

    public var imageContentData: Data? {
        Data(base64Encoded: imageContent)
    }
}
