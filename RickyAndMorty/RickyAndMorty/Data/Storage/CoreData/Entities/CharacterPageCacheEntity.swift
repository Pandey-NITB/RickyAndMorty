//
//  CharacterPageCacheEntity.swift
//  RickyAndMorty
//

import CoreData

@objc(CharacterPageCacheEntity)
final class CharacterPageCacheEntity: NSManagedObject {
    @NSManaged var cacheKey: String
    @NSManaged var payload: Data
    @NSManaged var updatedAt: Date
}

extension CharacterPageCacheEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CharacterPageCacheEntity> {
        NSFetchRequest<CharacterPageCacheEntity>(entityName: RickyAndMortyEntity.characterPageCache)
    }
}
