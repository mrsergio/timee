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
            List {
                ForEach(viewStore.entries, id: \.self) { entry in
                    EntryHistoryView(
                        entry: entry.title,
                        duration: entry.duration.humanReadableTime,
                        when: entry.startDate.humanReadableDate.lowercased()
                    )
                }
                .onDelete { (offsets: IndexSet) in
                    viewStore.send(.delete(offsets))
                }
            }
            .overlay {
                // Display 'no content' overlay when there are no entries found
                if viewStore.entries.isEmpty {
                    noContentView
                }
            }
            .safeAreaInset(edge: .bottom) {
                // New entry view at the very bottom of the screen (overlaps the main content)
                EntryLiveView(
                    state: viewStore.currentEntry == nil ? .idle : .active(viewStore.timeElapsed),
                    onStart: { (newEntryTitle: String) in
                        viewStore.send(.onNewEntryStart(newEntryTitle))
                    },
                    onStop: { (newEntryTitle: String) in
                        viewStore.send(.onNewEntryStop(newEntryTitle))
                    }
                )
                .padding([.top, .bottom], 16)
                .padding([.leading, .trailing], 12)
                .background(
                    Color.DarkPurple
                        .shadow(.drop(radius: 8))
                )
                .animation(
                    Animation.easeInOut(duration: 0.25),
                    value: viewStore.currentEntry == nil
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private var noContentView: some View {
        VStack(spacing: 4) {
            Text("No entries")
                .font(.title3)
                .foregroundColor(Color.DarkPurple)
            
            Text("add one below")
                .italic()
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.DarkPurple.opacity(0.75))
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
