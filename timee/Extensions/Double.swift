//
//  Double.swift
//  timee
//
//  Created by Sergii Simakhin on 2/12/23.
//

import Foundation

extension Double {
    var humanReadableTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        formatter.unitsStyle = .positional
        
        return formatter.string(from: TimeInterval(self)) ?? "??:??:??"
    }
}
