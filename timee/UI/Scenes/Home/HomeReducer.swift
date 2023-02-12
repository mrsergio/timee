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
        var entries: [Entry] = []
    }
    
    enum Action: Equatable {
        case onAppear
        case onAddEntry(String)
        
        case set([Entry])
        case add(Entry)
        case delete(Entry)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        print("action: \(action)")
        
        switch action {
            case .onAppear:
                return .task {
                    let entries = try await database.fetchEntries()
                    return .set(entries)
                }

            case .onAddEntry(let title):
                return .none
                
            case .set(let entries):
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
