//
//  RickyAndMortyModelVersion.swift
//  RickyAndMorty
//
//  Schema: RickyAndMorty.xcdatamodeld (edit in Xcode's model editor).
//

import Foundation

enum RickyAndMortyCoreData {
    /// Matches RickyAndMorty.xcdatamodeld (compiled to RickyAndMorty.momd).
    static let containerName = "RickyAndMorty"
}

enum RickyAndMortyEntity {
    static let favorite = "FavoriteEntity"
    static let characterPageCache = "CharacterPageCacheEntity"
    static let episodeCache = "EpisodeCacheEntity"
}
