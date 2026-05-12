//
//  URLSessionProtocol.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//

import Foundation

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

