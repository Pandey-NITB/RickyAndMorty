//
//  FetchCharactersUseCase.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


protocol FetchCharactersUseCase: Sendable {
    func execute(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters
}

struct DefaultFetchCharactersUseCase: FetchCharactersUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters {
        try await repository.fetchCharacters(page: page, name: name, status: status)
    }
}

