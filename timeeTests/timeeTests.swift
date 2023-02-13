//
//  timeeTests.swift
//  timeeTests
//
//  Created by Sergii Simakhin on 2/11/23.
//

import XCTest
import ComposableArchitecture
@testable import timee

final class timeeTests: XCTestCase {
    
    @MainActor
    func testAddEntry() async {
        // Prepare initial entries
        let entry1: Entry = Entry(id: 1, title: "First", startDate: Date())
        let entry2: Entry = Entry(id: 2, title: "Second", startDate: Date())
        
        let store = TestStore(
            initialState: HomeReducer.State(entries: [entry2, entry1]),
            reducer: HomeReducer()
        )
        
        // Prepare new entry
        let newEntry = Entry(id: 3, title: "Third", startDate: Date())
        
        // Add new entry
        await store.send(.add(newEntry)) {
            // Expect new entry to be inserted at the very top of array
            $0.entries = [newEntry, entry2, entry1]
        }
    }

    @MainActor
    func testDeleteEntry() async {
        // Prepare initial entries
        let entry1: Entry = Entry(id: 1, title: "First", startDate: Date())
        let entry2: Entry = Entry(id: 2, title: "Second", startDate: Date())
        
        let store = TestStore(
            initialState: HomeReducer.State(entries: [entry2, entry1]),
            reducer: HomeReducer()
        )
        
        // Delete entry with index = 1
        await store.send(.delete(IndexSet([1]))) {
            // Expect non-deleted entry to exist
            $0.entries = [entry2]
        }
    }
    
    @MainActor
    func testTimerTickAndReset() async {
        let store = TestStore(
            initialState: HomeReducer.State(),
            reducer: HomeReducer()
        ) {
            // Docs on `ImmediateClock` https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing/
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.onTimerTick) {
            // `state.timeElapsed` should set to 1 on tick
            $0.timeElapsed = 1
        }
        
        await store.send(.onTimerTick) {
            // `state.timeElapsed` should set to 2 on another tick
            $0.timeElapsed = 2
        }
        
        await store.send(.onTimerReset) {
            // `state.timeElapsed` should set to 0 on reset
            $0.timeElapsed = 0
        }
    }
}
