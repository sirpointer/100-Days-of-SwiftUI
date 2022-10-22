//
//  DataController.swift
//  Bookworm-CoreData
//
//  Created by Nikita Novikov on 29.08.2022.
//

import CoreData
import Foundation


class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Bookworm")
    
    init() {
        container.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        })
    }
}
