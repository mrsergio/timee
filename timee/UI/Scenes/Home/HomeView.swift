//
//  HomeView.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI

struct Entry: Hashable {
    var title: String
    var duration: Double // in seconds
    var date: Date
}

struct HomeView: View {
    @State var entries: [Entry] = [
        Entry(title: "Patient #1", duration: 955, date: Date()),
        Entry(title: "Patient #2", duration: 955, date: Date())
    ]
    
    var body: some View {
        VStack {
            List {
                Section("Today") {
                    ForEach(entries, id: \.self) { entry in
                        EntryHistoryView(entry: entry.title, duration: String(entry.duration), when: "today")
                    }
                }
                
                Section("Yesterday") {
                    ForEach(entries, id: \.self) { entry in
                        EntryHistoryView(entry: entry.title, duration: String(entry.duration), when: "today")
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}