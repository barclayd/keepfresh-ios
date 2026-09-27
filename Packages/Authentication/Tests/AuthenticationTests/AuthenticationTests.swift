@testable import Authentication
import Foundation
import Supabase
import Testing

@Suite(.serialized)
struct AuthenticationTests {
    private func session(expired: Bool = false) -> Session {
        Session(
            accessToken: "test-access-token", tokenType: "bearer", expiresIn: 3600,
            expiresAt: Date().addingTimeInterval(expired ? -3600 : 3600).timeIntervalSince1970,
            refreshToken: "test-refresh-token",
            user: User(
                id: UUID(), appMetadata: [:], userMetadata: [:], aud: "authenticated",
                createdAt: Date(), updatedAt: Date(), isAnonymous: true))
    }

    private func client(session: Session? = nil) throws -> SupabaseClient {
        let storage = MemoryStorage()
        if let session {
            try storage.store(key: "test-session", value: JSONEncoder().encode(session))
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [AuthURLProtocol.self]
        return SupabaseClient(
            supabaseURL: URL(string: "https://auth.example")!, supabaseKey: "test-key",
            options: .init(
                auth: .init(storage: storage, storageKey: "test-session", autoRefreshToken: false),
                global: .init(session: URLSession(configuration: configuration))))
    }

    @Test func validSessionKeepsExistingAccount() async throws {
        AuthURLProtocol.handle = { _ in
            Issue.record("A valid session should not need a network request")
            throw URLError(.notConnectedToInternet)
        }
        let existing = session()
        let client = try client(session: existing)

        try await Authentication(client: client).signInAnonymously()

        #expect(client.auth.currentUser?.id == existing.user.id)
    }

    @Test func missingSessionCreatesAnonymousAccount() async throws {
        let created = session()
        let body = try AuthClient.Configuration.jsonEncoder.encode(created)
        AuthURLProtocol.handle = { request in
            #expect(request.url?.path == "/auth/v1/signup")
            return (200, body)
        }
        let client = try client()

        try await Authentication(client: client).signInAnonymously()

        #expect(client.auth.currentUser?.id == created.user.id)
    }

    @Test func expiredSessionRefreshesSameAccount() async throws {
        let expired = session(expired: true)
        var refreshed = expired
        refreshed.expiresAt = Date().addingTimeInterval(3600).timeIntervalSince1970
        let body = try AuthClient.Configuration.jsonEncoder.encode(refreshed)
        AuthURLProtocol.handle = { request in
            #expect(request.url?.path == "/auth/v1/token")
            return (200, body)
        }
        let client = try client(session: expired)

        try await Authentication(client: client).signInAnonymously()

        #expect(client.auth.currentUser?.id == expired.user.id)
        #expect(client.auth.currentSession?.isExpired == false)
    }

    @Test func offlineRefreshDoesNotCreateAnotherAccount() async throws {
        AuthURLProtocol.handle = { request in
            #expect(request.url?.path == "/auth/v1/token")
            throw URLError(.notConnectedToInternet)
        }
        let expired = session(expired: true)
        let client = try client(session: expired)

        await #expect(throws: (any Error).self) {
            try await Authentication(client: client).signInAnonymously()
        }

        #expect(client.auth.currentUser?.id == expired.user.id)
        #expect(client.auth.currentSession?.refreshToken == expired.refreshToken)
    }

    @Test func rejectedRefreshDoesNotCreateAnotherAccount() async throws {
        AuthURLProtocol.handle = { request in
            #expect(request.url?.path == "/auth/v1/token")
            return (400, Data(#"{"code":"refresh_token_not_found","msg":"Invalid Refresh Token"}"#.utf8))
        }
        let expired = session(expired: true)
        let client = try client(session: expired)

        await #expect(throws: (any Error).self) {
            try await Authentication(client: client).signInAnonymously()
        }

        #expect(client.auth.currentUser?.id == expired.user.id)
    }
}

private final class MemoryStorage: AuthLocalStorage, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: Data] = [:]

    func store(key: String, value: Data) throws { lock.withLock { values[key] = value } }
    func retrieve(key: String) throws -> Data? { lock.withLock { values[key] } }
    func remove(key: String) throws { _ = lock.withLock { values.removeValue(forKey: key) } }
}

private final class AuthURLProtocol: URLProtocol, @unchecked Sendable {
    // Each test installs its handler before starting requests; the suite is serialized.
    nonisolated(unsafe) static var handle: (@Sendable (URLRequest) throws -> (Int, Data))!

    override class func canInit(with _: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, body) = try Self.handle(request)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
