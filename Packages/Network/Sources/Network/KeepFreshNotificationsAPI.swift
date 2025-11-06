import Foundation
import Models

public struct KeepFreshNotificationsAPI: Sendable {
    private let client: APIClient

    public init(baseURL: String = "https://notifications.keepfre.sh/") {
        client = APIClient(baseURL: baseURL)
    }

    // MARK: - Devices

    public func registerDevice(_ request: RegisterDeviceRequest) async throws {
        try await client.post(
            path: "v1/devices",
            body: request)
    }
}
