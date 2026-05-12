
//
//  NetworkService.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Foundation

protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

struct APIEndpoint: Equatable, Sendable {
    let path: String
    var queryItems: [URLQueryItem] = []
}


struct NetworkService: NetworkServiceProtocol {
    private let baseURL: URL
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let maxRetryCount: Int
    private let rateLimitRetryDelayNanoseconds: UInt64

    init(
        baseURL: URL = URL(string: "https://rickandmortyapi.com/api")!,
        session: URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        maxRetryCount: Int = 2,
        rateLimitRetryDelayNanoseconds: UInt64 = 800_000_000
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.maxRetryCount = maxRetryCount
        self.rateLimitRetryDelayNanoseconds = rateLimitRetryDelayNanoseconds
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let request = URLRequest(url: url)

        do {
            let (data, response) = try await data(for: request)
            guard response is HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decoding
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    private func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        for attempt in 0...maxRetryCount {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if (200...299).contains(httpResponse.statusCode) {
                return (data, response)
            }

            if httpResponse.statusCode == 429 {
                guard attempt < maxRetryCount else {
                    throw NetworkError.rateLimited
                }
                try await Task.sleep(nanoseconds: retryDelay(from: httpResponse, attempt: attempt))
                continue
            }

            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        throw NetworkError.rateLimited
    }

    private func retryDelay(from response: HTTPURLResponse, attempt: Int) -> UInt64 {
        if let retryAfter = response.value(forHTTPHeaderField: "Retry-After"),
           let seconds = Double(retryAfter) {
            return UInt64(seconds * 1_000_000_000)
        }

        return rateLimitRetryDelayNanoseconds * UInt64(attempt + 1)
    }
}
