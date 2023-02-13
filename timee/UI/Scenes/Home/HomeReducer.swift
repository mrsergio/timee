//
//  HomeReducer.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import ComposableArchitecture
import Foundation

struct HomeReducer: ReducerProtocol {
    @Dependency(\.database) var database
    @Dependency(\.continuousClock) var clock
    
    private enum TimerID {}

    struct State: Equatable {
        var entries: [Entry] = [] // list of all the entries fetched from DB
        var currentEntry: Entry? // the entry user may start from the footer; equals `nil` when timer is stopped
        var timeElapsed: Double = 0 // current entry timer
    }
    
    enum Action: Equatable {
        case onAppear
        case onBecomeActive
        
        case onNewEntryStart(String) // called on "Play" button tap
        case onNewEntryStop(String) // called on "Stop" button tap
        
        /**
         Timer-related actions called by reducer
         */
        case onTimerTick
        case onTimerReset
        
        /**
         A set of side-effects called by reducer to cleanup temporary variables right after new entry is added
        */
        case resetTimerAndCurrentEntry
        
        case setAllEntries([Entry])
        case setCurrentEntry(Entry?)
        
        case add(Entry)
        case delete(IndexSet)
        
        case populateRandomEntries
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            case .onAppear:
                return .task {
                    let entries = try await database.fetchEntries()
                    return .setAllEntries(entries)
                }
                
            case .onBecomeActive:
                /* App become active, update timer if there is one */
                guard let currentEntry = state.currentEntry else {
                    return .none
                }
                
                // Update time elapsed
                state.timeElapsed = currentEntry.startDate.distance(to: Date())
                
                return .none
                
            case .onNewEntryStart(let title):
                return .merge(
                    // Create timer and tick on every second
                    EffectTask.run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.onTimerTick)
                        }
                    }
                    .cancellable(id: TimerID.self, cancelInFlight: true),
                    
                    // Create new entry without an end date (which idicates it is a temporary/current entry timer)
                    EffectTask.task {
                        let newNoEndDateEntry: Entry = try await database.addEntry(
                            title: title,
                            startDate: Date()
                        )
                        return .setCurrentEntry(newNoEndDateEntry)
                    }
                )
                
            case .onNewEntryStop(let title):
                // Don't let empty title slip into database, no one likes empty titles
                let newEntryTitle: String = title.isEmpty ? "Untitled" : title
                
                guard let currentEntryId = state.currentEntry?.id else {
                    // If id is nil, then cleanup
                    return .run { send in
                        await send(.resetTimerAndCurrentEntry)
                    }
                }
                
                return .merge(
                    /**
                     Edit that entry (without an end date) with an updated title (if any)
                     and current time as an end date.
                     */
                    EffectTask.task(operation: {
                        guard let newEntry = try await database.editEntry(
                            id: currentEntryId,
                            title: newEntryTitle,
                            endDate: Date()
                        ) else {
                            // Cleanup on error
                            return .resetTimerAndCurrentEntry
                        }
                        
                        // Add just edited database entry to the list of entries to display
                        return .add(newEntry)
                    }),
                    
                    // Cleanup
                    EffectTask.task(operation: { .resetTimerAndCurrentEntry })
                )
                
            case .onTimerTick:
                state.timeElapsed += 1
                return .none
                
            case .onTimerReset:
                state.timeElapsed = 0
                return .none
                
            case .resetTimerAndCurrentEntry:
                return .merge(
                    // Set current entry to nil
                    EffectTask.task(operation: { .setCurrentEntry(nil) }),
                    
                    // Cancel the ticking timer
                    EffectTask.cancel(id: TimerID.self),
                    
                    // Nullify elapsed time count
                    EffectTask.task(operation: { .onTimerReset })
                )
                
            case .setCurrentEntry(let currentEntry):
                state.currentEntry = currentEntry
                return .none
                
            case .setAllEntries(let entries):
                state.entries = entries
                return .none
                
            case .add(let newEntry):
                state.entries.insert(newEntry, at: 0)
                return .none
                
            case .delete(let offsets):
                guard
                    let index = Array(offsets).first,
                    state.entries.indices.contains(index)
                else {
                    return .none
                }
                
                let entryId: Int64? = state.entries[index].id
                state.entries.remove(atOffsets: offsets)

                return EffectTask.run { _ in
                    try await database.deleteEntry(id: entryId)
                }
                
            case .populateRandomEntries:
                /* Generate random entries for preview purposes */
                
                let pastWeek: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                let yesterday: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                
                state.entries = [
                    Entry(id: 1004,
                          title: "Patient #5",
                          startDate: Date(),
                          endDate: Date().advanced(by: 60*8 + 24)
                    ),
                    Entry(id: 1003,
                          title: "Patient #4",
                          startDate: Date(),
                          endDate: Date().advanced(by: 60*48 + 12)
                    ),
                    Entry(id: 1002,
                          title: "Patient #3",
                          startDate: Date(),
                          endDate: Date().advanced(by: 60*14 + 14)
                    ),
                    Entry(id: 1001,
                          title: "Patient #2",
                          startDate: yesterday,
                          endDate: yesterday.advanced(by: 54*12 - 4)
                    ),
                    Entry(id: 1000,
                          title: "Patient #1",
                          startDate: pastWeek,
                          endDate: pastWeek.advanced(by: 13*12 - 58)
                    )
                ]
                
                return .none
        }
    }
}
