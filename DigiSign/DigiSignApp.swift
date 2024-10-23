//
//  DigiSignApp.swift
//  DigiSign
//
//  Created by Dev Reptech on 29/02/2024.
//

import SwiftUI

@main
struct DigiSignApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
