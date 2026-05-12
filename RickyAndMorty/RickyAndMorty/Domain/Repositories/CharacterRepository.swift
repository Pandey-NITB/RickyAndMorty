//
//  CharacterRepository.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


protocol CharacterRepository: Sendable {
    func fetchCharacters(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters
    func fetchEpisodes(ids: [Int]) async throws -> [Episode]
    func toggleFavorite(characterID: Int) async throws -> Bool
    func isFavorite(characterID: Int) async -> Bool
}

