//
//  CoreDataEpisodeCacheStore.swift
//  RickyAndMorty
//

import CoreData
import Foundation

final class CoreDataEpisodeCacheStore: EpisodeCacheStore, @unchecked Sendable {
    private let stack: CoreDataStack
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func save(_ episodes: [EpisodeDTO]) async {
        let context = stack.viewContext
        await context.perform {
            for episode in episodes {
                guard let data = try? self.encoder.encode(episode) else { continue }

                let request = EpisodeCacheEntity.fetchRequest()
                request.predicate = NSPredicate(format: "episodeID == %lld", Int64(episode.id))
                request.fetchLimit = 1

                let entity = (try? context.fetch(request).first) ?? EpisodeCacheEntity(context: context)
                entity.episodeID = Int64(episode.id)
                entity.payload = data
                entity.updatedAt = Date()
            }
            try? context.save()
        }
    }

    func load(ids: [Int]) async -> [EpisodeDTO]? {
        let context = stack.viewContext
        return await context.perform {
            let episodes = ids.compactMap { id -> EpisodeDTO? in
                let request = EpisodeCacheEntity.fetchRequest()
                request.predicate = NSPredicate(format: "episodeID == %lld", Int64(id))
                request.fetchLimit = 1
                guard let entity = try? context.fetch(request).first else { return nil }
                return try? self.decoder.decode(EpisodeDTO.self, from: entity.payload)
            }
            return episodes.count == ids.count ? episodes : nil
        }
    }
}
