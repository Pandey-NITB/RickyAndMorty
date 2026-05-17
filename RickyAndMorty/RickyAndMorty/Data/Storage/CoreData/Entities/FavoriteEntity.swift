//
//  FavoriteEntity.swift
//  RickyAndMorty
//

import CoreData

@objc(FavoriteEntity)
final class FavoriteEntity: NSManagedObject {
    @NSManaged var characterID: Int64
}

extension FavoriteEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<FavoriteEntity> {
        NSFetchRequest<FavoriteEntity>(entityName: RickyAndMortyEntity.favorite)
    }
}
