//
//  BLETestApp.swift
//  BLETest
//
//  Created by Jasjit Singh Chawla on 27/05/21.
//

import SwiftUI

@main
struct BLETestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TestView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
