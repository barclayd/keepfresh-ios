import Foundation

public struct RegisterDeviceRequest: Codable, Sendable {
    public let deviceToken: String
    public let platform: String
    public let appVersion: String
    public let environment: String

    public init(deviceToken: String, platform: String, appVersion: String, environment: String) {
        self.deviceToken = deviceToken
        self.platform = platform
        self.appVersion = appVersion
        self.environment = environment
    }
}
