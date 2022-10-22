//
//  EditView-ViewModel.swift
//  Bucket List
//
//  Created by Nikita Novikov on 19.09.2022.
//

import Foundation


@MainActor final class EditViewVM: ObservableObject {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    var location: Location
    
    @Published var name: String
    @Published var description: String
    
    @Published var loadingState = LoadingState.loading
    @Published var pages = [Page]()
    
    init(location: Location) {
        self.location = location
        _name = .init(initialValue: location.name)
        _description = .init(initialValue: location.description)
    }
    
    
    func fetchNearbyPlaces() async {
        // https://gist.github.com/twostraws/aa18008c3dd3997e133aa92bde2ad8c7
        
        //let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        //        guard let url = URL(string: urlString) else {
        //            print("Bad URL: \(urlString)")
        //            return
        //        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "en.wikipedia.org"
        components.path = "/w/api.php"
        components.queryItems = [
            URLQueryItem(name: "ggscoord", value: "\(location.coordinate.latitude)|\(location.coordinate.longitude)"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "prop", value: "coordinates|pageimages|pageterms"),
            URLQueryItem(name: "colimit", value: "50"),
            URLQueryItem(name: "piprop", value: "thumbnail"),
            URLQueryItem(name: "pithumbsize", value: "500"),
            URLQueryItem(name: "pilimit", value: "50"),
            URLQueryItem(name: "wbptterms", value: "description"),
            URLQueryItem(name: "generator", value: "geosearch"),
            URLQueryItem(name: "ggsradius", value: "10000"),
            URLQueryItem(name: "ggslimit", value: "50"),
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = components.url else {
            print("Bad URL: \(components.path)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(Result.self, from: data)
            pages = items.query.pages.values.sorted()
            loadingState = .loaded
        } catch {
            loadingState = .failed
            print(error.localizedDescription)
        }
    }
}
