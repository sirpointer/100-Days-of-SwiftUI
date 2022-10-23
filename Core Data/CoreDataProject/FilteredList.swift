//
//  FilteredList.swift
//  CoreDataProject
//
//  Created by Nikita Novikov on 02.09.2022.
//

import CoreData
import SwiftUI

struct FilteredList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>
    
    let content: (T) -> Content
    
    var body: some View {
        List(fetchRequest, id: \.self) { item in
            self.content(item)
        }
    }
    
    init(filterKey: String, filterValue: String, predicate: FilterPredicate, sortDescriptor: NSSortDescriptor, @ViewBuilder content: @escaping (T) -> Content) {
        if predicate != .none {
            _fetchRequest = FetchRequest<T>(sortDescriptors: [sortDescriptor], predicate: NSPredicate(format: "%K \(predicate.rawValue) %@", filterKey, filterValue))
        } else {
            _fetchRequest = FetchRequest<T>(sortDescriptors: [sortDescriptor])
        }
        
        self.content = content
    }
}


enum FilterPredicate: String, CaseIterable {
    case beginsWith = "BEGINSWITH"
    case equals = "=="
    case contains = "CONTAINS[c]"
    case none = "none"
    
    var title: String {
        switch self {
        case .beginsWith:
            return "begins with"
        case .equals:
            return "equals"
        case .contains:
            return "contains"
        case .none:
            return "none"
        }
    }
}

//struct FilteredList_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteredList(filter: "A")
//    }
//}
