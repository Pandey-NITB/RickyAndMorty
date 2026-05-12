//
//  Episode.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


struct Episode: Identifiable, Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let airDate: String
    let episodeCode: String
}

