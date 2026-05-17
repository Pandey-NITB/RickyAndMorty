//
//  CoreDataFavoritesStore.swift
//  RickyAndMorty
//

import CoreData
import Foundation

final class CoreDataFavoritesStore: FavoritesStore, @unchecked Sendable {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func ids() async -> Set<Int> {
        let context = stack.viewContext
        return await context.perform {
            let request = FavoriteEntity.fetchRequest()
            let entities = (try? context.fetch(request)) ?? []
            return Set(entities.map { Int($0.characterID) })
        }
    }

    func contains(_ id: Int) async -> Bool {
        await ids().contains(id)
    }

    func toggle(_ id: Int) async throws -> Bool {
        let context = stack.viewContext
        return try await context.perform {
            let request = FavoriteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "characterID == %lld", Int64(id))
            request.fetchLimit = 1

            if let existing = try context.fetch(request).first {
                context.delete(existing)
                try context.save()
                return false
            }

            let entity = FavoriteEntity(context: context)
            entity.characterID = Int64(id)
            try context.save()
            return true
        }
    }
}
