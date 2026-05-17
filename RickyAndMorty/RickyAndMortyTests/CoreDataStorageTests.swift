//
//  CoreDataStorageTests.swift
//  RickyAndMortyTests
//

import XCTest
@testable import RickyAndMorty

final class CoreDataStorageTests: XCTestCase {
    private var stack: CoreDataStack!
    private var userDefaults: UserDefaults!
    private var userDefaultsSuiteName: String!

    override func setUpWithError() throws {
        stack = try CoreDataStack(inMemory: true)
        userDefaultsSuiteName = "CoreDataStorageTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)!
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
        stack = nil
        userDefaults = nil
        userDefaultsSuiteName = nil
    }

    func testFavoritesToggleAddAndRemove() async throws {
        let store = CoreDataFavoritesStore(stack: stack)

        let added = try await store.toggle(42)
        XCTAssertTrue(added)
        let containsAfterAdd = await store.contains(42)
        XCTAssertTrue(containsAfterAdd)
        let idsAfterAdd = await store.ids()
        XCTAssertEqual(idsAfterAdd, Set([42]))

        let removed = try await store.toggle(42)
        XCTAssertFalse(removed)
        let containsAfterRemove = await store.contains(42)
        XCTAssertFalse(containsAfterRemove)
        let idsAfterRemove = await store.ids()
        XCTAssertTrue(idsAfterRemove.isEmpty)
    }

    func testCharacterCacheSaveAndLoad() async {
        let store = CoreDataCharacterCacheStore(stack: stack)
        let page = Self.sampleCharacterPage(name: "Rick Sanchez")

        await store.save(page, pageNumber: 1, name: "Rick", status: .alive)
        let loaded = await store.load(pageNumber: 1, name: "Rick", status: .alive)

        XCTAssertEqual(loaded, page)
    }

    func testCharacterCacheDifferentKeysAreIsolated() async {
        let store = CoreDataCharacterCacheStore(stack: stack)
        let pageA = Self.sampleCharacterPage(name: "Rick")
        let pageB = Self.sampleCharacterPage(name: "Morty")

        await store.save(pageA, pageNumber: 1, name: nil, status: nil)
        await store.save(pageB, pageNumber: 2, name: nil, status: nil)

        let loadedA = await store.load(pageNumber: 1, name: nil, status: nil)
        let loadedB = await store.load(pageNumber: 2, name: nil, status: nil)
        let loadedC = await store.load(pageNumber: 3, name: nil, status: nil)
        XCTAssertEqual(loadedA, pageA)
        XCTAssertEqual(loadedB, pageB)
        XCTAssertNil(loadedC)
    }

    func testEpisodeCacheSaveAndLoadAllIDs() async {
        let store = CoreDataEpisodeCacheStore(stack: stack)
        let episodes = [
            EpisodeDTO(id: 1, name: "Pilot", airDate: "December 2, 2013", episode: "S01E01"),
            EpisodeDTO(id: 2, name: "Lawnmower Dog", airDate: "December 9, 2013", episode: "S01E02")
        ]

        await store.save(episodes)
        let loaded = await store.load(ids: [1, 2])

        XCTAssertEqual(loaded, episodes)
    }

    func testEpisodeCacheReturnsNilWhenAnyEpisodeMissing() async {
        let store = CoreDataEpisodeCacheStore(stack: stack)
        await store.save([EpisodeDTO(id: 1, name: "Pilot", airDate: "December 2, 2013", episode: "S01E01")])

        let partialLoad = await store.load(ids: [1, 2])
        XCTAssertNil(partialLoad)
    }

    func testMigratorImportsFavoritesFromUserDefaults() async throws {
        userDefaults.set([7, 9], forKey: CacheKeyBuilder.favoritesKey)

        UserDefaultsToCoreDataMigrator(userDefaults: userDefaults, stack: stack).migrateIfNeeded()

        let store = CoreDataFavoritesStore(stack: stack)
        let favoriteIDs = await store.ids()
        XCTAssertEqual(favoriteIDs, Set([7, 9]))
        XCTAssertTrue(userDefaults.bool(forKey: CacheKeyBuilder.migrationCompletedKey))
    }

    func testMigratorImportsCharacterPageCacheFromUserDefaults() async throws {
        let page = Self.sampleCharacterPage(name: "Summer")
        let envelope = CharacterPageCacheEnvelope(page: page)
        let data = try JSONEncoder().encode(envelope)
        let key = CacheKeyBuilder.characterPageKey(pageNumber: 2, name: "Sum", status: .alive)
        userDefaults.set(data, forKey: key)

        UserDefaultsToCoreDataMigrator(userDefaults: userDefaults, stack: stack).migrateIfNeeded()

        let store = CoreDataCharacterCacheStore(stack: stack)
        let loadedPage = await store.load(pageNumber: 2, name: "Sum", status: .alive)
        XCTAssertEqual(loadedPage, page)
    }

    func testMigratorImportsEpisodeCacheFromUserDefaults() async throws {
        let episode = EpisodeDTO(id: 5, name: "Rixty Minutes", airDate: "March 17, 2014", episode: "S01E08")
        let data = try JSONEncoder().encode(episode)
        userDefaults.set(data, forKey: CacheKeyBuilder.episodeKey(id: 5))

        UserDefaultsToCoreDataMigrator(userDefaults: userDefaults, stack: stack).migrateIfNeeded()

        let store = CoreDataEpisodeCacheStore(stack: stack)
        let loadedEpisodes = await store.load(ids: [5])
        XCTAssertEqual(loadedEpisodes, [episode])
    }

    func testMigratorIsIdempotent() async throws {
        userDefaults.set([1], forKey: CacheKeyBuilder.favoritesKey)
        let migrator = UserDefaultsToCoreDataMigrator(userDefaults: userDefaults, stack: stack)

        migrator.migrateIfNeeded()
        migrator.migrateIfNeeded()

        let store = CoreDataFavoritesStore(stack: stack)
        let favoriteIDs = await store.ids()
        XCTAssertEqual(favoriteIDs, Set([1]))
    }

    func testCoreDataStackEnablesLightweightMigrationOptions() throws {
        let description = stack.container.persistentStoreDescriptions.first
        XCTAssertTrue(description?.shouldMigrateStoreAutomatically == true)
        XCTAssertTrue(description?.shouldInferMappingModelAutomatically == true)
    }
}

private extension CoreDataStorageTests {
    struct CharacterPageCacheEnvelope: Codable {
        let page: CharacterPageDTO
    }

    static func sampleCharacterPage(name: String) -> CharacterPageDTO {
        CharacterPageDTO(
            info: PageInfoDTO(next: nil),
            results: [
                CharacterDTO(
                    id: 1,
                    name: name,
                    status: "Alive",
                    species: "Human",
                    type: "",
                    gender: "Male",
                    origin: NamedResourceDTO(name: "Earth", url: ""),
                    location: NamedResourceDTO(name: "Earth", url: ""),
                    image: "https://example.com/image.png",
                    episode: ["https://rickandmortyapi.com/api/episode/1"]
                )
            ]
        )
    }
}
