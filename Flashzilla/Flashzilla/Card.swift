//
//  Card.swift
//  Flashzilla
//
//  Created by Nikita Novikov on 28.09.2022.
//

import Foundation


struct Card: Codable, Identifiable {
    let id: UUID
    
    let prompt: String
    let answer: String
    
    init(prompt: String, answer: String) {
        self.id = UUID()
        self.prompt = prompt
        self.answer = answer
    }
    
    
    // MARK: Codable
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.prompt = try container.decode(String.self, forKey: .prompt)
        self.answer = try container.decode(String.self, forKey: .answer)
    }
    
    enum CodingKeys: CodingKey {
        case prompt
        case answer
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.prompt, forKey: .prompt)
        try container.encode(self.answer, forKey: .answer)
    }
    
    
    private static var cardsStoragePath: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "Cards.json")
    }()
    
    static func save(cards: [Card]) {
        if let data = try? JSONEncoder().encode(cards),
           let jsonString = String(data: data, encoding: .utf8) {
            try? jsonString.write(to: cardsStoragePath, atomically: true, encoding: .utf8)
        }
    }
    
    static func load() -> [Card] {
        if let jsonString = try? String(contentsOf: cardsStoragePath),
           let jsonData = jsonString.data(using: .utf8),
           let cards = try? JSONDecoder().decode([Card].self, from: jsonData) {
            return cards
        } else {
            return []
        }
    }
    
    
    func clone() -> Card {
        Card(prompt: self.prompt, answer: self.answer)
    }
    
    static let example = Card(prompt: "Who playd the 13th Doctor Who?", answer: "Jodie Whittaker")
}
