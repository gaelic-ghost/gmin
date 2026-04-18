//
//  PersistenceController.swift
//  gmin
//
//  Created by Gale Williams on 4/17/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError(
                "gmin could not save preview Core Data records. Received \(nsError.domain) code \(nsError.code): \(nsError.localizedDescription)"
            )
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "gmin")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError(
                    "gmin could not load the Core Data persistent store at \(storeDescription.url?.path ?? "an unknown path"). Received \(error.domain) code \(error.code): \(error.localizedDescription)"
                )
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
