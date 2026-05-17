//
//  CacheKeyBuilder.swift
//  RickyAndMorty
//

import Foundation

enum CacheKeyBuilder {
    static let favoritesKey = "favoriteCharacterIDs"
    static let migrationCompletedKey = "didMigrateLocalStorageToCoreData_v1"

    static func characterPageKey(pageNumber: Int, name: String?, status: CharacterStatus?) -> String {
        "characters-page-\(pageNumber)-name-\(name ?? "")-status-\(status?.rawValue ?? "")"
    }

    static func episodeKey(id: Int) -> String {
        "episode-\(id)"
    }

    static func isCharacterPageCacheKey(_ key: String) -> Bool {
        key.hasPrefix("characters-page-")
    }

    static func isEpisodeCacheKey(_ key: String) -> Bool {
        key.hasPrefix("episode-")
    }

    static func episodeID(from key: String) -> Int? {
        guard isEpisodeCacheKey(key) else { return nil }
        return Int(key.dropFirst("episode-".count))
    }
}
