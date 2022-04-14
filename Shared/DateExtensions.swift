//
//  Extensions.swift
//  Intervals
//
//  Created by Matthew Roche on 10/10/2021.
//

import Foundation
import SpriteKit

// Make date stridable and create shortcuts to date and time descriptions
extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
    
    
    public func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
    
    public var formattedDateShortString: String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .none
        return dateformatter.string(from: self)
    }
    
    public var formattedDateLongString: String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        return dateformatter.string(from: self)
    }
    
    public var formattedTimeShortString: String {
        let dateformatter = DateFormatter()
        
        if Calendar.current.isDateInToday(self) {
            dateformatter.dateStyle = .none
            dateformatter.timeStyle = .short
        } else {
            dateformatter.dateStyle = .short
            dateformatter.timeStyle = .none
        }
        
        return dateformatter.string(from: self)
    }
    
    public var formattedDateTimeShortString: String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .short
        return dateformatter.string(from: self)
    }
}
