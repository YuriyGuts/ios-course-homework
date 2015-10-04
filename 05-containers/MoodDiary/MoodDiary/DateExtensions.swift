//
//  DateExtensions.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 22.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

extension NSDate: Comparable {
    
    func beginningOfDay() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        return calendar.dateFromComponents(components)
    }
    
    func beginningOfWeek() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        var weekBeginningDate: NSDate?
        if calendar.rangeOfUnit(.WeekOfYear, startDate: &weekBeginningDate, interval: nil, forDate: self) {
            return weekBeginningDate
        }
        return nil
    }
    
}

public func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

