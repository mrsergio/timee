//
//  Date.swift
//  timee
//
//  Created by Sergii Simakhin on 2/13/23.
//

import Foundation

extension Date {
    var humanReadableDate: String {
        if Calendar.current.isDateInToday(self) {
           return "Today"
       } else if Calendar.current.isDateInYesterday(self) {
           return "Yesterday"
       } else {
           return DateFormatter.HumanReadable.string(from: self)
       }
    }
}

extension DateFormatter {
    static let HumanReadable: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())
}
