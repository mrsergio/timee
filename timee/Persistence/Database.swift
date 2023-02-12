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
                    t.column("duration", .double).notNull()
                    t.column("date", .datetime).notNull()
                }
            }
        }
    }
}
