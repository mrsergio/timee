//
//  Entry.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import Foundation
import GRDB

struct Entry: Identifiable, Hashable {
    var id: Int64?
    var title: String
    var duration: Double // in seconds
    var date: Date
}

extension Entry: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let date = Column(CodingKeys.date)
    }
    
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

// MARK: - Entry Database Requests

extension DerivableRequest<Entry> {
    func orderedByDate() -> Self {
        order(Entry.Columns.date)
    }
}
