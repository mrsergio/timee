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
        case delete(Entry)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        print("action: \(action)")
        
        switch action {
            case .onAppear:
                return .task {
                    let entries = try await database.fetchEntries()
                    return .setAllEntries(entries)
                }
                
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
                
            case .delete(let entry):
                return .none
        }
    }
}
