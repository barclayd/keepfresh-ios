import Foundation
import Supabase

public final class Authentication: Sendable {
    private let client: SupabaseClient

    public static let shared = Authentication()

    public init() {
        client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey,
            options: SupabaseClientOptions(auth: .init(storage: KeychainLocalStorage(), flowType: .pkce)))
    }

    init(client: SupabaseClient) {
        self.client = client
    }

    public func signInAnonymously() async throws {
        do {
            _ = try await client.auth.session
        } catch AuthError.sessionMissing {
            // Only a genuinely missing session should create a new identity.
            // Network, refresh-token and server errors must preserve the existing account.
            try await client.auth.signInAnonymously()
        }
    }

    public func getAccessToken() async throws -> String? {
        try await client.auth.session.accessToken
    }
}
