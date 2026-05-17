//
//  UserDefaultsToCoreDataMigrator.swift
//  RickyAndMorty
//

import CoreData
import Foundation

/// One-time migration of favourites and JSON caches from UserDefaults into Core Data.
final class UserDefaultsToCoreDataMigrator: @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let stack: CoreDataStack

    init(userDefaults: UserDefaults = .standard, stack: CoreDataStack) {
        self.userDefaults = userDefaults
        self.stack = stack
    }

    func migrateIfNeeded() {
        guard !userDefaults.bool(forKey: CacheKeyBuilder.migrationCompletedKey) else { return }

        let context = stack.viewContext
        context.performAndWait {
            migrateFavorites(in: context)
            migrateCharacterPages(in: context)
            migrateEpisodes(in: context)
            try? context.save()
            userDefaults.set(true, forKey: CacheKeyBuilder.migrationCompletedKey)
        }
    }

    private func migrateFavorites(in context: NSManagedObjectContext) {
        let ids = userDefaults.array(forKey: CacheKeyBuilder.favoritesKey) as? [Int] ?? []
        for id in ids {
            let request = FavoriteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "characterID == %lld", Int64(id))
            request.fetchLimit = 1
            if let existing = try? context.fetch(request), !existing.isEmpty { continue }

            let entity = FavoriteEntity(context: context)
            entity.characterID = Int64(id)
        }
    }

    private func migrateCharacterPages(in context: NSManagedObjectContext) {
        for key in userDefaults.dictionaryRepresentation().keys where CacheKeyBuilder.isCharacterPageCacheKey(key) {
            guard let data = userDefaults.data(forKey: key) else { continue }

            let request = CharacterPageCacheEntity.fetchRequest()
            request.predicate = NSPredicate(format: "cacheKey == %@", key)
            request.fetchLimit = 1
            if let existing = try? context.fetch(request), !existing.isEmpty { continue }

            let entity = CharacterPageCacheEntity(context: context)
            entity.cacheKey = key
            entity.payload = data
            entity.updatedAt = Date()
        }
    }

    private func migrateEpisodes(in context: NSManagedObjectContext) {
        for key in userDefaults.dictionaryRepresentation().keys where CacheKeyBuilder.isEpisodeCacheKey(key) {
            guard let episodeID = CacheKeyBuilder.episodeID(from: key),
                  let data = userDefaults.data(forKey: key) else { continue }

            let request = EpisodeCacheEntity.fetchRequest()
            request.predicate = NSPredicate(format: "episodeID == %lld", Int64(episodeID))
            request.fetchLimit = 1
            if let existing = try? context.fetch(request), !existing.isEmpty { continue }

            let entity = EpisodeCacheEntity(context: context)
            entity.episodeID = Int64(episodeID)
            entity.payload = data
            entity.updatedAt = Date()
        }
    }
}
