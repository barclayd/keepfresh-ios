import Authentication
import Foundation

public actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = URL(string: baseURL)!
        self.session = session

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    private func addAuthorizationHeader(to request: inout URLRequest) async {
        if let token = try? await Authentication.shared.getAccessToken() {
            print(token)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    public func fetch<T: Decodable>(
        _ type: T.Type,
        path: String,
        queryParameters: [String: String]? = nil) async throws -> T
    {
        guard
            var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        else {
            throw APIError.invalidURL
        }

        if let queryParameters {
            components.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }

        return try decoder.decode(type, from: data)
    }

    public func post<T: Decodable>(
        _ type: T.Type,
        path: String,
        body: some Encodable) async throws -> T
    {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }

        return try decoder.decode(type, from: data)
    }

    public func post(
        path: String,
        body: some Encodable) async throws
    {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }
    }

    public func post<T: Decodable>(
        _ type: T.Type,
        path: String) async throws -> T
    {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }

        return try decoder.decode(type, from: data)
    }

    public func patch(
        path: String,
        body: some Encodable) async throws
    {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }
    }

    public func delete(path: String) async throws {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }
    }

    public func delete<T: Decodable>(
        _ type: T.Type,
        path: String) async throws -> T
    {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        await addAuthorizationHeader(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }

        return try decoder.decode(type, from: data)
    }
}

public enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, responseBody: String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid response from server"
        case let .httpError(statusCode, responseBody):
            "HTTP error \(statusCode): \(responseBody)"
        }
    }
}
