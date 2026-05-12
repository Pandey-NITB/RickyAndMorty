//
//  AppContainer.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//



import Foundation

@MainActor
final class AppContainer {
    private let repository: CharacterRepository

    init() {
        let networkService = NetworkService()
        let favoritesStore = UserDefaultsFavoritesStore()
        let cacheStore = UserDefaultsCharacterCacheStore()
        let episodeCacheStore = UserDefaultsEpisodeCacheStore()
        repository = RemoteCharacterRepository(
            networkService: networkService,
            favoritesStore: favoritesStore,
            cacheStore: cacheStore,
            episodeCacheStore: episodeCacheStore
        )
    }

    func makeCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(
            fetchCharactersUseCase: DefaultFetchCharactersUseCase(repository: repository),
            toggleFavoriteUseCase: DefaultToggleFavoriteUseCase(repository: repository),
            favoriteStatusUseCase: DefaultFavoriteStatusUseCase(repository: repository)
        )
    }

    func makeCharacterDetailViewModel(character: Character) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            character: character,
            fetchEpisodesUseCase: DefaultFetchCharacterEpisodesUseCase(repository: repository),
            toggleFavoriteUseCase: DefaultToggleFavoriteUseCase(repository: repository)
        )
    }
}
