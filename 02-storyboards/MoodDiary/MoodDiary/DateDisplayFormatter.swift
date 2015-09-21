//
//  DateDisplayFormatter.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

class DateDisplayFormatter {
    
    let settings: SettingsModel
    
    let dateFormatter: NSDateFormatter
    
    init(settings: SettingsModel) {
        self.settings = settings
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle

        if self.settings.includeTime {
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        else {
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        }
    }
    
    func format(date: NSDate) -> String {
        // TODO: Support relative dates.
        return dateFormatter.stringFromDate(date)
    }
}
