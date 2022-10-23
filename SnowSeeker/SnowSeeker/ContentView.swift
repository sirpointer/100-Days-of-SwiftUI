//
//  ContentView.swift
//  SnowSeeker
//
//  Created by Nikita Novikov on 06.10.2022.
//

import SwiftUI

extension View {
    @ViewBuilder func phoneOnlyNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
}


struct ContentView: View {
    let resorts: [Resort] = Bundle.main.decode("resorts.json")
    
    @State private var sortOrder = Resort.SortOrder.none
    @State private var sortOrderShowingAlert = false
    
    @StateObject var favorites = Favorites()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List(filteredResorts.sortedResorts(by: sortOrder)) { resort in
                NavigationLink {
                    ResortView(resort: resort)
                } label: {
                    HStack {
                        Image(resort.country)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 25)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.black, lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(resort.name)
                                .font(.headline)
                            Text("\(resort.runs) runs")
                        }
                        
                        if favorites.contains(resort) {
                            Spacer()
                            
                            Image(systemName: "heart.fill")
                                .accessibilityLabel("This is a favorite resort")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Resorts")
            .searchable(text: $searchText, prompt: "Search for a resort")
            .toolbar {
                Button {
                    sortOrderShowingAlert = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
            .alert("Choose the sort order", isPresented: $sortOrderShowingAlert) {
                Button("None") { sortOrder = .none }
                Button("Alphabetical order") { sortOrder = .alphabetical }
                Button("By country") { sortOrder = .country }
                Button("Cancel") { }
            }
            
            WelcomeView()
        }
        .phoneOnlyNavigationView()
        .environmentObject(favorites)
    }
    
    var filteredResorts: [Resort] {
        if searchText.isEmpty {
            return resorts
        } else {
            return resorts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
