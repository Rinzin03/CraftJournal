//
//  CraftJournalApp.swift
//  CraftJournal
//
//  Created by iMac01 on 9/29/26.
//

import SwiftUI
internal import CoreData

@main
struct CraftJournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
