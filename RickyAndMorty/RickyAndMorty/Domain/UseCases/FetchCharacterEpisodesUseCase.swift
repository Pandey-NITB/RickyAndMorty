//
//  FetchCharacterEpisodesUseCase.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


protocol FetchCharacterEpisodesUseCase: Sendable {
    func execute(ids: [Int]) async throws -> [Episode]
}

struct DefaultFetchCharacterEpisodesUseCase: FetchCharacterEpisodesUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(ids: [Int]) async throws -> [Episode] {
        try await repository.fetchEpisodes(ids: ids)
    }
}

