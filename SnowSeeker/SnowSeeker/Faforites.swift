//
//  Faforites.swift
//  SnowSeeker
//
//  Created by Nikita Novikov on 11.10.2022.
//

import Foundation

class Favorites: ObservableObject {
    private var resorts: Set<String> = []
    private let saveKey = "Favorites"
    
    init() {
        self.resorts = load()
    }
    
    func contains(_ resort: Resort) -> Bool {
        resorts.contains(resort.id)
    }
    
    func add(_ resort: Resort) {
        objectWillChange.send()
        resorts.insert(resort.id)
        save()
    }
    
    func remove(_ resort: Resort) {
        objectWillChange.send()
        resorts.remove(resort.id)
        save()
    }
    
    func save() {
        if let jsonString = try? JSONEncoder().encode(resorts) {
            try? jsonString.write(to: getDocumentDirectory())
        }
    }
    
    func load() -> Set<String> {
        if let jsonString = try? String(contentsOf: getDocumentDirectory(), encoding: .utf8),
           let resortsList = try? JSONDecoder().decode(Set<String>.self, from: jsonString.data(using: .utf8)!) {
            return resortsList
        } else {
            return []
        }
    }
    
    private func getDocumentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: saveKey)
    }
}
