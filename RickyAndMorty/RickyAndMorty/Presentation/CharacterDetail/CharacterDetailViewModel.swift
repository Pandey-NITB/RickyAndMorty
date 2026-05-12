//
//  CharacterDetailViewModel.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Combine
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var character: Character
    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var isLoadingEpisodes = false
    @Published private(set) var errorMessage: String?

    private let fetchEpisodesUseCase: FetchCharacterEpisodesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    init(
        character: Character,
        fetchEpisodesUseCase: FetchCharacterEpisodesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.character = character
        self.fetchEpisodesUseCase = fetchEpisodesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    func onAppear() {
        guard episodes.isEmpty else { return }
        Task {
            await loadEpisodes()
        }
    }

    func toggleFavorite(onChange: ((Int, Bool) -> Void)? = nil) {
        Task {
            do {
                let isFavorite = try await toggleFavoriteUseCase.execute(characterID: character.id)
                character.isFavorite = isFavorite
                onChange?(character.id, isFavorite)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func loadEpisodes() async {
        isLoadingEpisodes = true
        errorMessage = nil
        do {
            episodes = try await fetchEpisodesUseCase.execute(ids: character.episodeIDs)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingEpisodes = false
    }

    func clearError() {
        errorMessage = nil
    }
}
