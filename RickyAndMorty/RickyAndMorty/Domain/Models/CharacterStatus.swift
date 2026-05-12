//
//  CharacterStatus.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


enum CharacterStatus: String, CaseIterable, Codable, Equatable, Sendable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .alive:
            return "Alive"
        case .dead:
            return "Dead"
        case .unknown:
            return "Unknown"
        }
    }
}

