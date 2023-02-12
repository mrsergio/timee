//
//  Entry.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import Foundation
import GRDB

struct Entry: Identifiable, Hashable {
    internal init(id: Int64? = nil, title: String = "", startDate: Date = Date(), endDate: Date? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var id: Int64?
    var title: String
    var startDate: Date
    var endDate: Date?
    
    /// in seconds (computed variable, not stored in DB)
    var duration: Double {
        if let endDate {
            let startDateComponents = Calendar.current
                .dateComponents([.second], from: startDate)
            
            let endDateComponents = Calendar.current
                .dateComponents([.second], from: endDate)
            
            let duration = Calendar.current
                .dateComponents([.second], from: startDateComponents, to: endDateComponents)
                .second
            
            return Double(abs(duration ?? 0))
            
        } else {
            return 0.0
        }
    }
}

// MARK: - Database Protocols

extension Entry: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let date = Column(CodingKeys.startDate).desc // sort descending when ordering by date
    }
    
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

// MARK: - Database Requests

extension DerivableRequest<Entry> {
    func orderedByDate() -> Self {
        order(Entry.Columns.date)
    }
}
