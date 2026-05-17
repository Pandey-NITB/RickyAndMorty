
//
//  CharacterCacheStore.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Foundation

protocol CharacterCacheStore: Sendable {
    func save(_ page: CharacterPageDTO, pageNumber: Int, name: String?, status: CharacterStatus?) async
    func load(pageNumber: Int, name: String?, status: CharacterStatus?) async -> CharacterPageDTO?
}

final class UserDefaultsCharacterCacheStore: CharacterCacheStore, @unchecked Sendable {
    private struct CacheEnvelope: Codable {
        let page: CharacterPageDTO
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save(_ page: CharacterPageDTO, pageNumber: Int, name: String?, status: CharacterStatus?) async {
        guard let data = try? encoder.encode(CacheEnvelope(page: page)) else { return }
        userDefaults.set(data, forKey: CacheKeyBuilder.characterPageKey(pageNumber: pageNumber, name: name, status: status))
    }

    func load(pageNumber: Int, name: String?, status: CharacterStatus?) async -> CharacterPageDTO? {
        guard let data = userDefaults.data(forKey: CacheKeyBuilder.characterPageKey(pageNumber: pageNumber, name: name, status: status)) else {
            return nil
        }
        return try? decoder.decode(CacheEnvelope.self, from: data).page
    }

}

protocol EpisodeCacheStore: Sendable {
    func save(_ episodes: [EpisodeDTO]) async
    func load(ids: [Int]) async -> [EpisodeDTO]?
}

final class UserDefaultsEpisodeCacheStore: EpisodeCacheStore, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save(_ episodes: [EpisodeDTO]) async {
        for episode in episodes {
            guard let data = try? encoder.encode(episode) else { continue }
            userDefaults.set(data, forKey: CacheKeyBuilder.episodeKey(id: episode.id))
        }
    }

    func load(ids: [Int]) async -> [EpisodeDTO]? {
        let episodes = ids.compactMap { id -> EpisodeDTO? in
            guard let data = userDefaults.data(forKey: CacheKeyBuilder.episodeKey(id: id)) else { return nil }
            return try? decoder.decode(EpisodeDTO.self, from: data)
        }
        return episodes.count == ids.count ? episodes : nil
    }

}
