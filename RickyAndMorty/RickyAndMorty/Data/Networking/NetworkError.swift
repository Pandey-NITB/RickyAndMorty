
//
//  NetworkError.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//

import Foundation

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case invalidResponse
    case rateLimited
    case statusCode(Int)
    case decoding
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .rateLimited:
            return "The server is receiving too many requests. Please wait a moment and try again."
        case .statusCode(let code):
            return "The server returned status code \(code)."
        case .decoding:
            return "We could not read the server response."
        case .transport(let message):
            return message
        }
    }
}
