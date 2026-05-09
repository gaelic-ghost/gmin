//
//  gminApp.swift
//  gmin
//
//  Created by Gale Williams on 4/17/26.
//

import SwiftUI
import CoreData

@main
struct gminApp: App {
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
			MainWindowView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
		Settings {
			SettingsUtilityWindow()
		}
    }
}
