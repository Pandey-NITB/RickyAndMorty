//
//  CharacterListViewModel.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Combine
import Foundation

@MainActor
final class CharacterListViewModel: ObservableObject {
    @Published private(set) var characters: [Character] = []
    @Published private(set) var isInitialLoading = true
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = "" {
        didSet { scheduleSearch() }
    }
    @Published var selectedStatus: CharacterStatus? {
        didSet { resetAndLoad() }
    }

    private let fetchCharactersUseCase: FetchCharactersUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let favoriteStatusUseCase: FavoriteStatusUseCase
    private var currentPage = 0
    private var hasNextPage = true
    private var hasRequestedInitialLoad = false
    private var requestedPages: Set<Int> = []
    private var searchTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var loadGeneration = 0

    init(
        fetchCharactersUseCase: FetchCharactersUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        favoriteStatusUseCase: FavoriteStatusUseCase
    ) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.favoriteStatusUseCase = favoriteStatusUseCase
    }

    deinit {
        searchTask?.cancel()
        loadTask?.cancel()
    }

    func onAppear() {
        if hasRequestedInitialLoad {
            refreshFavoriteStatuses()
        } else {
            loadFirstPage()
        }
    }

    func loadFirstPage() {
        hasRequestedInitialLoad = true
        loadGeneration += 1
        currentPage = 0
        hasNextPage = true
        requestedPages = []
        characters = []
        loadPage(1, isInitialLoad: true, generation: loadGeneration)
    }

    func loadNextPageIfNeeded(currentCharacter: Character) {
        guard characters.last?.id == currentCharacter.id else { return }
        guard hasNextPage, !isInitialLoading, !isLoadingNextPage else { return }
        loadPage(currentPage + 1, isInitialLoad: false, generation: loadGeneration)
    }

    func setStatusFilter(_ status: CharacterStatus?) {
        guard selectedStatus != status else { return }
        selectedStatus = status
    }

    func toggleFavorite(character: Character) {
        Task {
            do {
                let isFavorite = try await toggleFavoriteUseCase.execute(characterID: character.id)
                updateFavorite(characterID: character.id, isFavorite: isFavorite)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func applyFavoriteStatus(characterID: Int, isFavorite: Bool) {
        updateFavorite(characterID: characterID, isFavorite: isFavorite)
    }

    func refreshFavoriteStatuses() {
        guard !characters.isEmpty else { return }

        Task { [weak self] in
            guard let self else { return }
            var refreshedCharacters: [Character] = []

            for character in characters {
                var refreshedCharacter = character
                refreshedCharacter.isFavorite = await favoriteStatusUseCase.isFavorite(characterID: character.id)
                refreshedCharacters.append(refreshedCharacter)
            }

            characters = refreshedCharacters
        }
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            self?.resetAndLoad()
        }
    }

    private func resetAndLoad() {
        loadTask?.cancel()
        loadFirstPage()
    }

    private func loadPage(_ page: Int, isInitialLoad: Bool, generation: Int) {
        guard !requestedPages.contains(page) else { return }
        requestedPages.insert(page)

        if isInitialLoad {
            loadTask?.cancel()
        }
        if isInitialLoad {
            isInitialLoading = true
        } else {
            isLoadingNextPage = true
        }
        errorMessage = nil

        let name = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let status = selectedStatus

        loadTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if generation == loadGeneration {
                    if isInitialLoad {
                        isInitialLoading = false
                    } else {
                        isLoadingNextPage = false
                    }
                }
            }

            do {
                if !isInitialLoad {
                    try await Task.sleep(nanoseconds: 250_000_000)
                }
                let result = try await fetchCharactersUseCase.execute(
                    page: page,
                    name: name.isEmpty ? nil : name,
                    status: status
                )
                guard !Task.isCancelled, generation == loadGeneration else { return }
                currentPage = result.currentPage
                hasNextPage = result.hasNextPage
                characters = isInitialLoad ? result.characters : characters + result.characters
            } catch {
                guard generation == loadGeneration else { return }
                if Task.isCancelled {
                    requestedPages.remove(page)
                    return
                }
                requestedPages.remove(page)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updateFavorite(characterID: Int, isFavorite: Bool) {
        characters = characters.map { character in
            guard character.id == characterID else { return character }
            var updatedCharacter = character
            updatedCharacter.isFavorite = isFavorite
            return updatedCharacter
        }
    }
}
