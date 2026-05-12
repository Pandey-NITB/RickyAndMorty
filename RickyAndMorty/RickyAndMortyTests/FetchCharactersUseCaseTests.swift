//
//  RemoteCharacterRepository.swift
//  FetchCharactersUseCaseTests
//
//  Created by Prashant Pandey on 12/05/26.
//


import XCTest
@testable import RickyAndMorty

final class FetchCharactersUseCaseTests: XCTestCase {
    func testExecuteCallsRepositoryWithFiltersAndReturnsMappedResult() async throws {
        let repository = MockCharacterRepository()
        repository.charactersResult = PaginatedCharacters(
            characters: [
                Character(
                    id: 1,
                    name: "Rick Sanchez",
                    status: .alive,
                    species: "Human",
                    type: "",
                    gender: "Male",
                    origin: "Earth",
                    location: "Citadel",
                    imageURL: "",
                    episodeIDs: [1, 2],
                    isFavorite: true
                )
            ],
            currentPage: 3,
            hasNextPage: false
        )
        let useCase = DefaultFetchCharactersUseCase(repository: repository)

        let result = try await useCase.execute(page: 3, name: "Rick", status: .alive)

        XCTAssertEqual(repository.fetchCharactersCalls, [.init(page: 3, name: "Rick", status: .alive)])
        XCTAssertEqual(result.characters.first?.name, "Rick Sanchez")
        XCTAssertEqual(result.currentPage, 3)
        XCTAssertFalse(result.hasNextPage)
    }
}

private final class MockCharacterRepository: CharacterRepository, @unchecked Sendable {
    struct FetchCharactersCall: Equatable {
        let page: Int
        let name: String?
        let status: CharacterStatus?
    }

    var charactersResult = PaginatedCharacters(characters: [], currentPage: 1, hasNextPage: false)
    private(set) var fetchCharactersCalls: [FetchCharactersCall] = []

    func fetchCharacters(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters {
        fetchCharactersCalls.append(.init(page: page, name: name, status: status))
        return charactersResult
    }

    func fetchEpisodes(ids: [Int]) async throws -> [Episode] {
        []
    }

    func toggleFavorite(characterID: Int) async throws -> Bool {
        false
    }

    func isFavorite(characterID: Int) async -> Bool {
        false
    }
}

