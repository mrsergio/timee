//
//  timeeApp.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI

@main
struct timeeApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .navigationTitle("Timee")
            }
        }
    }
}
