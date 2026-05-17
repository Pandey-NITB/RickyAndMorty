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

    init(coreDataStack: CoreDataStack? = nil) {
        let stack: CoreDataStack
        if let coreDataStack {
            stack = coreDataStack
        } else if let loadedStack = try? CoreDataStack() {
            stack = loadedStack
        } else {
            fatalError("Failed to load Core Data persistent store")
        }

        UserDefaultsToCoreDataMigrator(stack: stack).migrateIfNeeded()

        let networkService = NetworkService()
        let favoritesStore = CoreDataFavoritesStore(stack: stack)
        let cacheStore = CoreDataCharacterCacheStore(stack: stack)
        let episodeCacheStore = CoreDataEpisodeCacheStore(stack: stack)
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
