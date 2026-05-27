//
//  UntilThenApp.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/21/26.
//

import SwiftUI
import TipKit

@main
struct UntilThenApp: App {
    var body: some Scene {
        WindowGroup {
            EventsScreen()
                .task {
                    #if DEBUG
                    // Reset tips for testing
                    try? Tips.resetDatastore()
                    #endif
                    
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
    }
}
