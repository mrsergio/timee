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

    struct State: Equatable {
        var entries: [Entry] = [] // list of all the entries fetched from DB
        var currentEntry: Entry? // the entry user may start from the footer; equals `nil` when timer is stopped
    }
    
    enum Action: Equatable {
        case onAppear
        
        case onNewEntryStart(String)
        case onNewEntryStop(String)
        
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
                // Create new entry without an end date (which idicates it is a temporary/current entry timer)
                return .task {
                    let newNoEndDateEntry: Entry = try await database.addEntry(
                        title: title,
                        startDate: Date()
                    )
                    return .setCurrentEntry(newNoEndDateEntry)
                }
                
            case .onNewEntryStop(let title):
                // Don't let empty title slip into database, no one likes empty titles
                let newEntryTitle: String = title.isEmpty ? "Untitled" : title
                
                guard let currentEntryId = state.currentEntry?.id else {
                    // If id is nil, then nullify the current entry
                    return .run { send in
                        await send(.setCurrentEntry(nil))
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
                            // On error, nullify the current entry
                            return .setCurrentEntry(nil)
                        }
                        
                        // Add just edited database entry to the list of entries to display
                        return .add(newEntry)
                    }),
                    
                    // Set current entry to nil
                    EffectTask.task(operation: { .setCurrentEntry(nil) })
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
