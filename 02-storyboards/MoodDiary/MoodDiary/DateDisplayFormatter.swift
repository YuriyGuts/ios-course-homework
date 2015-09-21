//
//  DateDisplayFormatter.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

class DateDisplayFormatter {
    
    let settings: Settings
    
    let dateFormatter: NSDateFormatter
    
    init(settings: Settings) {
        self.settings = settings
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle

        if self.settings.includeTime {
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        else {
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        }
        
        dateFormatter.doesRelativeDateFormatting = self.settings.useRelativeDates
    }
    
    func format(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
}
