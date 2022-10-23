//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Nikita Novikov on 21.09.2022.
//

import CodeScanner
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case byRecent, byName
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSortTypeDialog = false
    @State private var sort: SortType = .byRecent
    
    let filter: FilterType
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects) { prospect in
                    ProspectView(prospect: prospect)
                }
            }
                .navigationTitle(title)
                .toolbar {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                    
                    Button {
                        isShowingSortTypeDialog = true
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .confirmationDialog("Choose how to sort", isPresented: $isShowingSortTypeDialog) {
                        Button("By name") { sort = .byName }
                        Button("By recent") { sort = .byRecent }
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
                }
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
        switch sort {
        case .byRecent:
            return filteredProspects.sorted(by: { $0.timeStamp < $1.timeStamp })
        case .byName:
            return filteredProspects.sorted(by: { $0.name < $1.name })
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let success):
            let details = success.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            withAnimation(.easeOut) {
                prospects.add(person)
            }
        case .failure(let failure):
            print("Scanning failed: \(failure.localizedDescription).")
        }
    }
}

struct ProspectView: View {
    let prospect: Prospect
    
    @EnvironmentObject var prospects: Prospects
    
    @State private var isShowingRemoveProspectAlert = false
    
    var body: some View {
        HStack {
            Image(systemName: !prospect.isContacted ? "person.crop.circle.badge.xmark" : "person.crop.circle.fill.badge.checkmark")
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(!prospect.isContacted ? .blue : .green)
            
            VStack(alignment: .leading) {
                Text(prospect.name)
                    .font(.headline)
                Text(prospect.emailAddress)
                    .foregroundColor(.secondary)
                
                Text(prospect.timeStamp, style: .date)
            }
        }
        .swipeActions {
            if prospect.isContacted {
                Button {
                    withAnimation(.easeOut) {
                        prospects.toggle(prospect)
                    }
                } label: {
                    Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                }
                .tint(.blue)
            } else {
                Button {
                    withAnimation(.easeOut) {
                        prospects.toggle(prospect)
                    }
                } label: {
                    Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                }
                .tint(.green)
                
                Button {
                    prospects.addNotification(for: prospect)
                } label: {
                    Label("Remind me", systemImage: "bell")
                }
                .tint(.orange)
            }
            
            Button {
                isShowingRemoveProspectAlert = true
            } label: {
                Label("Remove", systemImage: "trash.circle.fill")
            }
            .tint(.red)
        }
        .alert("Do you want to remove \(prospect.name)", isPresented: $isShowingRemoveProspectAlert) {
            Button("Remove", role: .destructive) {
                withAnimation(.easeOut) {
                    prospects.remove(prospect)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects.testData)
    }
}
