protocol ToggleFavoriteUseCase: Sendable {
    func execute(characterID: Int) async throws -> Bool
}

protocol FavoriteStatusUseCase: Sendable {
    func isFavorite(characterID: Int) async -> Bool
}


//
//  DefaultToggleFavoriteUseCase.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


struct DefaultToggleFavoriteUseCase: ToggleFavoriteUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(characterID: Int) async throws -> Bool {
        try await repository.toggleFavorite(characterID: characterID)
    }
}

struct DefaultFavoriteStatusUseCase: FavoriteStatusUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func isFavorite(characterID: Int) async -> Bool {
        await repository.isFavorite(characterID: characterID)
    }
}
