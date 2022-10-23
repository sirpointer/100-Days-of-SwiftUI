//
//  DataController.swift
//  CoreDataProject
//
//  Created by Nikita Novikov on 01.09.2022.
//

import CoreData
import Foundation

public class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "CoreDataProject")
    
    init() {
        container.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                return
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            
        })
        
//        var a: NSFetchRequest<Country>
//        a = Country.fetchRequest()
//        let b = try! container.viewContext.fetch(a)
//        print(b.map { $0.fullName })
//        print(b.flatMap { $0.candyArray }.map { $0.wrappedName })
//        print("")
    }
}
