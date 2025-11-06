import Foundation

public struct RegisterDeviceRequest: Codable, Sendable {
    public let deviceToken: String
    public let platform: String
    public let appVersion: String

    public init(deviceToken: String, platform: String, appVersion: String) {
        self.deviceToken = deviceToken
        self.platform = platform
        self.appVersion = appVersion
    }
}
