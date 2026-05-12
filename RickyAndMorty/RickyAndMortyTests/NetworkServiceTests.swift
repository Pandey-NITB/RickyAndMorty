//
//  NetworkServiceTests.swift
//  RickyAndMortyTests
//
//  Created by Prashant Pandey on 12/05/26.
//


import Foundation
import XCTest
@testable import RickyAndMorty

final class NetworkServiceTests: XCTestCase {
    func testSuccessfulDecode() async throws {
        let session = MockURLSession()
        session.data = """
        {
          "id": 1,
          "name": "Pilot",
          "air_date": "December 2, 2013",
          "episode": "S01E01"
        }
        """.data(using: .utf8)!
        session.response = HTTPURLResponse(
            url: URL(string: "https://rickandmortyapi.com/api/episode/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let service = NetworkService(session: session)

        let episode: EpisodeDTO = try await service.request(APIEndpoint(path: "episode/1"))

        XCTAssertEqual(episode.name, "Pilot")
        XCTAssertEqual(session.lastRequest?.url?.absoluteString, "https://rickandmortyapi.com/api/episode/1")
    }

    func testMapsHTTPErrorStatusCode() async {
        let session = MockURLSession()
        session.data = Data()
        session.response = HTTPURLResponse(
            url: URL(string: "https://rickandmortyapi.com/api/character")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        let service = NetworkService(session: session)

        do {
            let _: EpisodeDTO = try await service.request(APIEndpoint(path: "character"))
            XCTFail("Expected status code error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .statusCode(500))
        }
    }

    func testMapsRateLimitAfterRetriesAreExhausted() async {
        let session = MockURLSession()
        session.data = Data()
        session.response = HTTPURLResponse(
            url: URL(string: "https://rickandmortyapi.com/api/character")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )!
        let service = NetworkService(session: session, maxRetryCount: 0)

        do {
            let _: EpisodeDTO = try await service.request(APIEndpoint(path: "character"))
            XCTFail("Expected rate limit error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .rateLimited)
        }
    }

    func testRetriesRateLimitedRequest() async throws {
        let session = MockURLSession()
        session.responses = [
            (
                Data(),
                HTTPURLResponse(
                    url: URL(string: "https://rickandmortyapi.com/api/episode/1")!,
                    statusCode: 429,
                    httpVersion: nil,
                    headerFields: nil
                )!
            ),
            (
                """
                {
                  "id": 1,
                  "name": "Pilot",
                  "air_date": "December 2, 2013",
                  "episode": "S01E01"
                }
                """.data(using: .utf8)!,
                HTTPURLResponse(
                    url: URL(string: "https://rickandmortyapi.com/api/episode/1")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        ]
        let service = NetworkService(
            session: session,
            maxRetryCount: 1,
            rateLimitRetryDelayNanoseconds: 1
        )

        let episode: EpisodeDTO = try await service.request(APIEndpoint(path: "episode/1"))

        XCTAssertEqual(episode.name, "Pilot")
        XCTAssertEqual(session.requestCount, 2)
    }

    func testMapsDecodingError() async {
        let session = MockURLSession()
        session.data = Data("{}".utf8)
        session.response = HTTPURLResponse(
            url: URL(string: "https://rickandmortyapi.com/api/episode/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let service = NetworkService(session: session)

        do {
            let _: EpisodeDTO = try await service.request(APIEndpoint(path: "episode/1"))
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .decoding)
        }
    }
}

private final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var data = Data()
    var response: URLResponse = URLResponse()
    var responses: [(Data, URLResponse)] = []
    private(set) var lastRequest: URLRequest?
    private(set) var requestCount = 0

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        requestCount += 1
        if !responses.isEmpty {
            return responses.removeFirst()
        }
        return (data, response)
    }
}
