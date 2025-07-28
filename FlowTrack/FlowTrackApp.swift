//
//  FlowTrackApp.swift
//  FlowTrack
//
//  Created by Rajeev  Upadhyay on 28/07/25.
//

import SwiftUI

@main
struct FlowTrackApp: App {
    let persistenceController = CoreDataManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
