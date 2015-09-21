//
//  DiaryEntry.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

class DiaryEntry {
    let date: NSDate
    var title: String?
    var body: NSAttributedString?
    var mood: DiaryEntryMood?
    
    init(date: NSDate, title: String?=nil, body: NSAttributedString?=nil, mood: DiaryEntryMood?=nil) {
        self.date = date
        self.title = title
        self.body = body
        self.mood = mood
    }
}
