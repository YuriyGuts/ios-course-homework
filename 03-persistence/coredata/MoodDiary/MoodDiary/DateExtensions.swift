//
//  DateExtensions.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 22.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

extension NSDate {
    
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        return calendar.dateFromComponents(components)!
    }
    
}
