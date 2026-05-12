//
//  RemoteCharacterRepository.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//

import Foundation

struct RemoteCharacterRepository: CharacterRepository {
    private let networkService: NetworkServiceProtocol
    private let favoritesStore: FavoritesStore
    private let cacheStore: CharacterCacheStore
    private let episodeCacheStore: EpisodeCacheStore

    init(
        networkService: NetworkServiceProtocol,
        favoritesStore: FavoritesStore,
        cacheStore: CharacterCacheStore,
        episodeCacheStore: EpisodeCacheStore
    ) {
        self.networkService = networkService
        self.favoritesStore = favoritesStore
        self.cacheStore = cacheStore
        self.episodeCacheStore = episodeCacheStore
    }

    func fetchCharacters(page: Int, name: String?, status: CharacterStatus?) async throws -> PaginatedCharacters {
        let endpoint = APIEndpoint(
            path: "character",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                name.map { URLQueryItem(name: "name", value: $0) },
                status.map { URLQueryItem(name: "status", value: $0.rawValue.lowercased()) }
            ].compactMap { $0 }
        )

        do {
            let dto: CharacterPageDTO = try await networkService.request(endpoint)
            await cacheStore.save(dto, pageNumber: page, name: name, status: status)
            return await mapPage(dto, page: page)
        } catch {
            if let cachedPage = await cacheStore.load(pageNumber: page, name: name, status: status) {
                return await mapPage(cachedPage, page: page)
            }
            throw error
        }
    }

    func fetchEpisodes(ids: [Int]) async throws -> [Episode] {
        guard !ids.isEmpty else { return [] }

        do {
            if ids.count == 1 {
                let dto: EpisodeDTO = try await networkService.request(APIEndpoint(path: "episode/\(ids[0])"))
                await episodeCacheStore.save([dto])
                return [dto.toDomain()]
            }

            let joinedIDs = ids.map(String.init).joined(separator: ",")
            let dto: [EpisodeDTO] = try await networkService.request(APIEndpoint(path: "episode/\(joinedIDs)"))
            await episodeCacheStore.save(dto)
            return dto.map { $0.toDomain() }
        } catch {
            if let cachedEpisodes = await episodeCacheStore.load(ids: ids) {
                return cachedEpisodes.map { $0.toDomain() }
            }
            throw error
        }
    }

    func toggleFavorite(characterID: Int) async throws -> Bool {
        try await favoritesStore.toggle(characterID)
    }

    func isFavorite(characterID: Int) async -> Bool {
        await favoritesStore.contains(characterID)
    }

    private func mapPage(_ dto: CharacterPageDTO, page: Int) async -> PaginatedCharacters {
        let favoriteIDs = await favoritesStore.ids()
        return PaginatedCharacters(
            characters: dto.results.map { $0.toDomain(isFavorite: favoriteIDs.contains($0.id)) },
            currentPage: page,
            hasNextPage: dto.info.next != nil
        )
    }
}
