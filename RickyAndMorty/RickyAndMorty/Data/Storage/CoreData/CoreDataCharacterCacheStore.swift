//
//  CoreDataCharacterCacheStore.swift
//  RickyAndMorty
//

import CoreData
import Foundation

final class CoreDataCharacterCacheStore: CharacterCacheStore, @unchecked Sendable {
    private struct CacheEnvelope: Codable {
        let page: CharacterPageDTO
    }

    private let stack: CoreDataStack
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func save(_ page: CharacterPageDTO, pageNumber: Int, name: String?, status: CharacterStatus?) async {
        guard let data = try? encoder.encode(CacheEnvelope(page: page)) else { return }
        let cacheKey = CacheKeyBuilder.characterPageKey(pageNumber: pageNumber, name: name, status: status)
        let context = stack.viewContext
        await context.perform {
            let request = CharacterPageCacheEntity.fetchRequest()
            request.predicate = NSPredicate(format: "cacheKey == %@", cacheKey)
            request.fetchLimit = 1

            let entity = (try? context.fetch(request).first) ?? CharacterPageCacheEntity(context: context)
            entity.cacheKey = cacheKey
            entity.payload = data
            entity.updatedAt = Date()
            try? context.save()
        }
    }

    func load(pageNumber: Int, name: String?, status: CharacterStatus?) async -> CharacterPageDTO? {
        let cacheKey = CacheKeyBuilder.characterPageKey(pageNumber: pageNumber, name: name, status: status)
        let context = stack.viewContext
        return await context.perform {
            let request = CharacterPageCacheEntity.fetchRequest()
            request.predicate = NSPredicate(format: "cacheKey == %@", cacheKey)
            request.fetchLimit = 1
            guard let entity = try? context.fetch(request).first else { return nil }
            return try? self.decoder.decode(CacheEnvelope.self, from: entity.payload).page
        }
    }
}
