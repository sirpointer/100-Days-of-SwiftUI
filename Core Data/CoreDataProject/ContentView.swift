//
//  ContentView.swift
//  CoreDataProject
//
//  Created by Nikita Novikov on 01.09.2022.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
//    @FetchRequest(sortDescriptors: [
//        SortDescriptor(\.shortName),
//    ]) var countries: FetchedResults<Country>
    
    @State private var filterPredicate: FilterPredicate = .none
    @State private var filterValue = ""
    @State private var ascending = false
    
    var body: some View {
        VStack {
            FilteredList(filterKey: "fullName", filterValue: filterValue, predicate: filterPredicate, sortDescriptor: NSSortDescriptor(key: "shortName", ascending: ascending)) { (country: Country) in
                Section(country.wrappedFullName) {
                    ForEach(country.candyArray, id: \.self) { candy in
                        Text(candy.wrappedName)
                    }
                }
            }
            
            Toggle("Sort ascending", isOn: $ascending.animation())
            
            Picker("Filter predicate", selection: $filterPredicate) {
                ForEach(FilterPredicate.allCases, id: \.self) { fp in
                    Text(fp.title)
                        .tag(fp)
                }
            }
            
            if filterPredicate != .none {
                TextField("Filter value", text: $filterValue)
                    .padding(.horizontal)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
