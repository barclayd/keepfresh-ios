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

    public func signInAnonymously() async throws {
        if await (try? client.auth.session) != nil {
            return
        }

        try await client.auth.signInAnonymously()
    }

    public func getAccessToken() async throws -> String? {
        try await client.auth.session.accessToken
    }
}
