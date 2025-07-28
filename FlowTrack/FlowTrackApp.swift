//
//  FlowTrackApp.swift
//  FlowTrack
//
//  Created by Rajeev  Upadhyay on 28/07/25.
//

import SwiftUI

@main
struct FlowTrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
