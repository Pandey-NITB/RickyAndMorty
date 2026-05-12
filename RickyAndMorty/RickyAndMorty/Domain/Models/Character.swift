
//
//  Character.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


struct Character: Identifiable, Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: String
    let origin: String
    let location: String
    let imageURL: String
    let episodeIDs: [Int]
    var isFavorite: Bool
}

