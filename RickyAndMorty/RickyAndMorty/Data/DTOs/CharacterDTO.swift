//
//  CharacterDTO.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Foundation

struct CharacterPageDTO: Codable, Equatable {
    let info: PageInfoDTO
    let results: [CharacterDTO]
}

struct PageInfoDTO: Codable, Equatable {
    let next: String?
}

struct CharacterDTO: Codable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: NamedResourceDTO
    let location: NamedResourceDTO
    let image: String
    let episode: [String]
}

struct NamedResourceDTO: Codable, Equatable {
    let name: String
    let url: String
}

extension CharacterDTO {
    func toDomain(isFavorite: Bool) -> Character {
        Character(
            id: id,
            name: name,
            status: CharacterStatus(rawValue: status) ?? .unknown,
            species: species,
            type: type,
            gender: gender,
            origin: origin.name,
            location: location.name,
            imageURL: image,
            episodeIDs: episode.compactMap { Int($0.split(separator: "/").last ?? "") },
            isFavorite: isFavorite
        )
    }
}

