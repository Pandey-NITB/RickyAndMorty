//
//  EpisodeCacheEntity.swift
//  RickyAndMorty
//

import CoreData

@objc(EpisodeCacheEntity)
final class EpisodeCacheEntity: NSManagedObject {
    @NSManaged var episodeID: Int64
    @NSManaged var payload: Data
    @NSManaged var updatedAt: Date
}

extension EpisodeCacheEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<EpisodeCacheEntity> {
        NSFetchRequest<EpisodeCacheEntity>(entityName: RickyAndMortyEntity.episodeCache)
    }
}
