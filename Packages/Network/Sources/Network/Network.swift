import Foundation

public actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = URL(string: baseURL)!
        self.session = session
    }

    public func fetch<T: Decodable>(
        _ type: T.Type,
        path: String,
        queryParameters: [String: String]? = nil
    ) async throws -> T {
        guard
            var components = URLComponents(
                url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true
            )
        else {
            throw APIError.invalidURL
        }

        if let queryParameters = queryParameters {
            components.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            throw APIError.httpError(statusCode: httpResponse.statusCode, responseBody: errorBody)
        }

        return try decoder.decode(type, from: data)
    }

    public func post<T: Decodable, B: Encodable>(
        _ type: T.Type,
        path: String,
        body: B
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
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
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case let .httpError(statusCode, responseBody):
            return "HTTP error \(statusCode): \(responseBody)"
        }
    }
}
