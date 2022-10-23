//
//  EditCards.swift
//  Flashzilla
//
//  Created by Nikita Novikov on 03.10.2022.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards: [Card] = []
    
    @State private var newPromt = ""
    @State private var newAnswer = ""
    
    init() { }
    
    fileprivate init(cards: [Card]) {
        self._cards = .init(initialValue: cards)
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                Section("Add new card") {
                    TextField("Promt", text: $newPromt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add card", action: addCard)
                }
                
                Section {
                    ForEach(cards) { card in
                        VStack(alignment: .leading) {
                            Text(card.prompt)
                                .font(.headline)
                                
                            Text(card.answer)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .toolbar {
                Button("Done", action: done)
            }
            .navigationTitle("Edit cards")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
            .onAppear(perform: loadData)
        }
    }

    private func loadData() {
        self.cards = Card.load()
    }
    
    private func addCard() {
        let trimmedPromt = newPromt.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPromt.isEmpty, !trimmedAnswer.isEmpty else { return }
        
        cards.insert(Card(prompt: trimmedPromt, answer: trimmedAnswer), at: 0)
        newPromt = ""
        newAnswer = ""
        Card.save(cards: cards)
    }
    
    private func removeCards(atOffsets offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        Card.save(cards: cards)
    }
    
    private func done() {
        dismiss()
    }
}

struct EditCards_Previews: PreviewProvider {
    static var previews: some View {
        EditCards(cards: Array<Card>(repeating: .example, count: 10))
    }
}
