//
//  SwiftuiappApp.swift
//  Swiftuiapp
//
//  Created by Neetesh Gupta on 17/11/2020.
//

import SwiftUI

@main
struct SwiftuiappApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
