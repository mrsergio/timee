//
//  HomeView.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI
import ComposableArchitecture

struct Entry: Hashable {
    var title: String
    var duration: Double // in seconds
    var date: Date
}

struct HomeView: View {
    let store: StoreOf<HomeReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottom) {
                VStack {
                    List {
                        Section("Today") {
                            ForEach(viewStore.entries, id: \.self) { entry in
                                EntryHistoryView(entry: entry.title, duration: String(entry.duration), when: "today")
                            }
                        }
                        
                        Section("Yesterday") {
                            ForEach(viewStore.entries, id: \.self) { entry in
                                EntryHistoryView(entry: entry.title, duration: String(entry.duration), when: "today")
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                EntryLiveView(entry: "", state: .idle)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom], 16)
                    .padding([.leading, .trailing], 12)
                    .background(
                        Color.DarkPurple
                            .shadow(.drop(radius: 8))
                    )
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(
                initialState: HomeReducer.State(
                    entries: [
                        Entry(title: "Patient #1", duration: 955, date: Date()),
                        Entry(title: "Patient #2", duration: 955, date: Date())
                    ]
                ),
                reducer: HomeReducer()
            )
        )
    }
}
