//
//  Bookworm_CoreDataApp.swift
//  Bookworm-CoreData
//
//  Created by Nikita Novikov on 29.08.2022.
//

import SwiftUI

@main
struct Bookworm_CoreDataApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
