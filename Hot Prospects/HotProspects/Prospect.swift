//
//  Prospect.swift
//  HotProspects
//
//  Created by Nikita Novikov on 21.09.2022.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var timeStamp = Date.now
    fileprivate(set) var isContacted = false
    
}

struct Me: Codable, Equatable {
    var name: String
    var email: String
}


@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    @Published private(set) var me: Me
    
    private let saveKey = "SavedData"
    private let saveMeKey = "MeData"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey), let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
            people = decoded
        } else {
            people = []
        }
        
        if let jsonData = try? Data(contentsOf: Prospects.meSavedDataPath),
           let me = try? JSONDecoder().decode(Me.self, from: jsonData) {
            self.me = me
        } else {
            me = Me(name: "Anonymous", email: "you@yoursite.com")
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func remove(_ prospect: Prospect) {
        people.removeAll(where: { $0.id == prospect.id })
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    
    private static var meSavedDataPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathExtension("me.json")
    }
    
    private func saveMe() {
        if let encoded = try? JSONEncoder().encode(me),
           let json = String(data: encoded, encoding: .utf8) {
            do {
                try json.write(to: Prospects.meSavedDataPath, atomically: true, encoding: .utf8)
            } catch {
                print("\(Prospects.meSavedDataPath.absoluteString)\n\(error.localizedDescription)")
            }
        }
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    
    func setMe(_ me: Me) {
        self.me = me
        saveMe()
    }
    
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
    
    
    static var testData: Prospects {
        let prospects = Prospects()
        
        let contacted = Prospect()
        contacted.name = "Nikita"
        contacted.emailAddress = "nikita@gmail.com"
        contacted.isContacted = true
        
        let uncontacted = Prospect()
        uncontacted.name = "Dasha"
        uncontacted.emailAddress = "dasha@gmail.com"
        uncontacted.isContacted = false
        
        prospects.people.append(contacted)
        prospects.people.append(uncontacted)
        
        return prospects
    }
}
