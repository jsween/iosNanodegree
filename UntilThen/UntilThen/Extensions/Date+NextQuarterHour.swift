//
//  Date+NextQuarter.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/24/26.
//

import Foundation

extension Date {
    /// Rounds the date up to the next 15-minute interval.
    /// e.g. 10:32 -> 10:45, 10:45 -> 11:00
    var nextQuarterHour: Date {
        let interval: TimeInterval = 15 * 60
        return Date(timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate / interval).rounded(.up) * interval)
    }
}
