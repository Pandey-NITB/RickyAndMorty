//
//  FavoritesStore.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Foundation

protocol FavoritesStore: Sendable {
    func ids() async -> Set<Int>
    func contains(_ id: Int) async -> Bool
    func toggle(_ id: Int) async throws -> Bool
}

final class UserDefaultsFavoritesStore: FavoritesStore, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "favoriteCharacterIDs") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func ids() async -> Set<Int> {
        Set(userDefaults.array(forKey: key) as? [Int] ?? [])
    }

    func contains(_ id: Int) async -> Bool {
        await ids().contains(id)
    }

    func toggle(_ id: Int) async throws -> Bool {
        var currentIDs = await ids()
        let isFavorite: Bool
        if currentIDs.contains(id) {
            currentIDs.remove(id)
            isFavorite = false
        } else {
            currentIDs.insert(id)
            isFavorite = true
        }
        userDefaults.set(Array(currentIDs), forKey: key)
        return isFavorite
    }
}
