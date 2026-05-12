//
//  RemoteCharacterRepository.swift
//  CharacterListViewModelTests
//
//  Created by Prashant Pandey on 12/05/26.
//



import XCTest
@testable import RickyAndMorty

@MainActor
final class CharacterListViewModelTests: XCTestCase {
    func testInitialLoadPopulatesCharacters() async throws {
        let fetchUseCase = MockFetchCharactersUseCase()
        fetchUseCase.results[1] = PaginatedCharacters(
            characters: [.stub(id: 1, name: "Rick")],
            currentPage: 1,
            hasNextPage: true
        )
        let viewModel = CharacterListViewModel(
            fetchCharactersUseCase: fetchUseCase,
            toggleFavoriteUseCase: MockToggleFavoriteUseCase(),
            favoriteStatusUseCase: MockFavoriteStatusUseCase()
        )

        viewModel.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.characters.map(\.name), ["Rick"])
        XCTAssertEqual(fetchUseCase.requests.first?.page, 1)
    }

    func testPaginationLoadsNextPageWhenLastCharacterAppears() async throws {
        let fetchUseCase = MockFetchCharactersUseCase()
        fetchUseCase.results[1] = PaginatedCharacters(
            characters: [.stub(id: 1, name: "Rick")],
            currentPage: 1,
            hasNextPage: true
        )
        fetchUseCase.results[2] = PaginatedCharacters(
            characters: [.stub(id: 2, name: "Morty")],
            currentPage: 2,
            hasNextPage: false
        )
        let viewModel = CharacterListViewModel(
            fetchCharactersUseCase: fetchUseCase,
            toggleFavoriteUseCase: MockToggleFavoriteUseCase(),
            favoriteStatusUseCase: MockFavoriteStatusUseCase()
        )

        viewModel.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)
        viewModel.loadNextPageIfNeeded(currentCharacter: viewModel.characters[0])
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.characters.map(\.name), ["Rick", "Morty"])
        XCTAssertEqual(fetchUseCase.requests.map(\.page), [1, 2])
    }

    func testDebouncedSearchResetsAndRequestsName() async throws {
        let fetchUseCase = MockFetchCharactersUseCase()
        fetchUseCase.results[1] = PaginatedCharacters(
            characters: [.stub(id: 1, name: "Summer")],
            currentPage: 1,
            hasNextPage: false
        )
        let viewModel = CharacterListViewModel(
            fetchCharactersUseCase: fetchUseCase,
            toggleFavoriteUseCase: MockToggleFavoriteUseCase(),
            favoriteStatusUseCase: MockFavoriteStatusUseCase()
        )

        viewModel.searchText = "Summer"
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(fetchUseCase.requests.last?.name, "Summer")
        XCTAssertEqual(viewModel.characters.map(\.name), ["Summer"])
    }

    func testStaleInitialLoadDoesNotOverwriteDebouncedSearchResults() async throws {
        let fetchUseCase = ControlledFetchCharactersUseCase()
        let viewModel = CharacterListViewModel(
            fetchCharactersUseCase: fetchUseCase,
            toggleFavoriteUseCase: MockToggleFavoriteUseCase(),
            favoriteStatusUseCase: MockFavoriteStatusUseCase()
        )

        viewModel.loadFirstPage()
        try await Task.sleep(nanoseconds: 50_000_000)
        viewModel.searchText = "Summer"
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(viewModel.characters.map(\.name), ["Summer"])
        XCTAssertFalse(viewModel.isInitialLoading)

        fetchUseCase.completeInitialLoad()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.characters.map(\.name), ["Summer"])
        XCTAssertEqual(fetchUseCase.requests.map(\.name), [nil, "Summer"])
    }
}

private final class MockFetchCharactersUseCase: FetchCharactersUseCase, @unchecked Sendable {
    struct Request: Equatable {
        let page: Int
        let name: String?
        let status: CharacterStatus?
    }

    var results: [Int: PaginatedCharacters] = [:]
    private(set) var requests: [Request] = []

    func execute(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters {
        requests.append(Request(page: page, name: name, status: status))
        return results[page] ?? PaginatedCharacters(characters: [], currentPage: page, hasNextPage: false)
    }
}

private final class MockToggleFavoriteUseCase: ToggleFavoriteUseCase, @unchecked Sendable {
    func execute(characterID: Int) async throws -> Bool {
        true
    }
}

private final class MockFavoriteStatusUseCase: FavoriteStatusUseCase, @unchecked Sendable {
    var favoriteIDs: Set<Int> = []

    func isFavorite(characterID: Int) async -> Bool {
        favoriteIDs.contains(characterID)
    }
}

private final class ControlledFetchCharactersUseCase: FetchCharactersUseCase, @unchecked Sendable {
    private(set) var requests: [MockFetchCharactersUseCase.Request] = []
    private var initialContinuation: CheckedContinuation<PaginatedCharacters, Never>?

    func execute(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters {
        requests.append(.init(page: page, name: name, status: status))

        if name == "Summer" {
            return PaginatedCharacters(
                characters: [.stub(id: 2, name: "Summer")],
                currentPage: page,
                hasNextPage: false
            )
        }

        return await withCheckedContinuation { continuation in
            initialContinuation = continuation
        }
    }

    func completeInitialLoad() {
        initialContinuation?.resume(
            returning: PaginatedCharacters(
                characters: [.stub(id: 1, name: "Rick")],
                currentPage: 1,
                hasNextPage: true
            )
        )
        initialContinuation = nil
    }
}

private extension Character {
    static func stub(id: Int, name: String) -> Character {
        Character(
            id: id,
            name: name,
            status: .alive,
            species: "Human",
            type: "",
            gender: "Male",
            origin: "Earth",
            location: "Citadel",
            imageURL: "https://example.com/avatar.png",
            episodeIDs: [1],
            isFavorite: false
        )
    }
}
