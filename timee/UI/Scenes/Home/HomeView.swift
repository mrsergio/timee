//
//  HomeView.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottom) {
                VStack {
                    List {
                        Section("Today") {
                            ForEach(viewStore.entries, id: \.self) { entry in
                                EntryHistoryView(entry: entry.title, duration: entry.duration.humanReadableTime, when: "today")
                            }
                        }
                        
                        Section("Yesterday") {
                            ForEach(viewStore.entries, id: \.self) { entry in
                                EntryHistoryView(entry: entry.title, duration: entry.duration.humanReadableTime, when: "today")
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                EntryLiveView(
                    state: viewStore.currentEntry == nil ? .idle : .active,
                    onStart: { (newEntryTitle: String) in
                        viewStore.send(.onNewEntryStart(newEntryTitle))
                    },
                    onStop: { (newEntryTitle: String) in
                        viewStore.send(.onNewEntryStop(newEntryTitle))
                    }
                )
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom], 16)
                .padding([.leading, .trailing], 12)
                .background(
                    Color.DarkPurple
                        .shadow(.drop(radius: 8))
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
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
                        Entry(id: 1, title: "Patient #1"),
                        Entry(id: 2, title: "Patient #2")
                    ]
                ),
                reducer: HomeReducer()
            )
        )
    }
}
