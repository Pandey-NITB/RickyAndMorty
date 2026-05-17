//
//  CoreDataStack.swift
//  RickyAndMorty
//

import CoreData
import Foundation

enum CoreDataStackError: Error {
    case loadPersistentStoresFailed(underlying: Error)
}

final class CoreDataStack: @unchecked Sendable {
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(
        inMemory: Bool = false
    ) throws {
        container = NSPersistentContainer(name: RickyAndMortyCoreData.containerName)

        let description = NSPersistentStoreDescription()
        if inMemory {
            description.type = NSInMemoryStoreType
        } else {
            description.url = Self.defaultStoreURL()
        }
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            throw CoreDataStackError.loadPersistentStoresFailed(underlying: loadError)
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    private static func defaultStoreURL() -> URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = directory.appendingPathComponent("RickAndMorty", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("RickAndMorty.sqlite")
    }
}
