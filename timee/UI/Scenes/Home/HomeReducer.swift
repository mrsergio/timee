//
//  HomeReducer.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import ComposableArchitecture

struct HomeReducer: ReducerProtocol {
    
    struct State: Equatable {
        var entries: [Entry] = []
    }
    
    enum Action: Equatable {
        case add(Entry)
        case delete(Entry)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        print("action: \(action)")
        
        switch action {
            case .add(let entry):
                return .none
                
            case .delete(let entry):
                return .none
        }
    }
}
