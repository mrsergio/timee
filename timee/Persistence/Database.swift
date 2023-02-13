//
//  Database.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import Foundation
import GRDB
import Dependencies

struct Database {
    /// Provides access to the database
    private var db: DatabaseQueue
    
    /// Creates an `Database`, and make sure the database schema is ready
    init() {
        let fileManager = FileManager()
        
        do {
            /* Create / connect to the database on disk */
            
            // Locate Application Support directory
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            
            // Create database folder
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to the database
            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            self.db = try DatabaseQueue(path: dbURL.path)
            try createSchema()
            
        } catch {
            /* As a fallback, create / connect to the database in memory */
            self.db = try! DatabaseQueue()
            try? createSchema()
        }
    }
    
    private func createSchema() throws {
        /* Create `entry` table */
        let entryTableName = "entry"
        try db.write { db in
            if try db.tableExists(entryTableName) == false {
                try db.create(table: "entry") { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("title", .text).notNull()
                    t.column("startDate", .datetime).notNull()
                    t.column("endDate", .datetime)
                }
            }
        }
    }
}

extension Database {
    
    func addEntry(title: String, startDate: Date, endDate: Date? = nil) async throws -> Entry {
        var newEntry = Entry(
            id: nil,
            title: title,
            startDate: startDate,
            endDate: endDate
        )
        
        newEntry = try await db.write { [newEntry] db in
            try newEntry.saved(db) // guaranteed non-nil `id` after save
        }
        
        return newEntry
    }
    
    func editEntry(id: Int64?, title: String, endDate: Date) async throws -> Entry? {
        try await db.write { db in
            var editingEntry = try Entry.find(db, id: id)
            editingEntry.title = title
            editingEntry.endDate = endDate
            return try editingEntry.updateAndFetch(db)
        }
    }
    
    @discardableResult func deleteEntry(id: Int64?) async throws -> Bool {
        try await db.write { db in
            try Entry.deleteOne(db, id: id)
        }
    }
    
    func fetchEntries() async throws -> [Entry] {
        try await db.read { db in
            let entries: [Entry] = try Entry.all()
                .orderedByDate()
                .fetchAll(db)
                .filter({ $0.endDate != nil }) // filter out invalid / temporary entries without end date
            
            return entries
        }
    }
}

// - MARK: Composable Architecture `@Dependency` key support

private enum DatabaseKey: DependencyKey {
    static let liveValue = Database()
    static let testValue = Database()
}

extension DependencyValues {
    var database: Database {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}
