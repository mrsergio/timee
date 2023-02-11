//
//  timeeApp.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct timeeApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(
                    store: Store(
                        initialState: HomeReducer.State(entries: []),
                        reducer: HomeReducer()
                    )
                )
                .navigationTitle("Timee")
            }
        }
    }
}
