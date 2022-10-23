//
//  Resort.swift
//  SnowSeeker
//
//  Created by Nikita Novikov on 06.10.2022.
//

import Foundation

struct Resort: Codable, Identifiable {
    enum SortOrder {
        case none, alphabetical, country
    }
    
    let id: String
    let name: String
    let country: String
    let description: String
    let imageCredit: String
    let price: Int
    let size: Int
    let snowDepth: Int
    let elevation: Int
    let runs: Int
    let facilities: [String]
    
    var facilityTypes: [Facility] {
        facilities.map(Facility.init)
    }
    
    private static let allResorts: [Resort] = Bundle.main.decode("resorts.json")
    static let example = allResorts[0]
}

extension [Resort] {
    func sortedResorts(by sortOrder: Resort.SortOrder) -> [Resort] {
        switch sortOrder {
        case .none:
            return self
        case .alphabetical:
            return self.sorted(by: { $0.name < $1.name })
        case .country:
            return self.sorted(by: { lhs, rhs in
                if lhs.country == rhs.country {
                    return lhs.name < rhs.name
                } else {
                    return lhs.country < rhs.country
                }
            })
        }
    }
}
