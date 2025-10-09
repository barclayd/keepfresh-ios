import Foundation
import Supabase

public actor AuthenticationClient {
    private let client: SupabaseClient
    private let keychain = Keychain()

    public init(supabaseURL: URL, supabaseKey: String) {
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey)
    }

    public func signInAnonymously() async throws {
        let token = try? keychain.get("accessToken")

        if token != nil {
            return
        }

        let session = try await client.auth.signInAnonymously()

        try? keychain.save(session.accessToken, for: "accessToken")
    }
}
