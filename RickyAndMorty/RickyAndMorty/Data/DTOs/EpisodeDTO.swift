
//
//  EpisodeDTO.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//

struct EpisodeDTO: Codable, Equatable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
}

extension EpisodeDTO {
    func toDomain() -> Episode {
        Episode(id: id, name: name, airDate: airDate, episodeCode: episode)
    }
}

