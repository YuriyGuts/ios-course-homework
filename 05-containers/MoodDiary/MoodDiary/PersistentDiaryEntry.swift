//
//  PersistentDiaryEntry.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 23.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation
import CoreData

class PersistentDiaryEntry: NSManagedObject {
    
    @NSManaged var date: NSDate?
    
    @NSManaged var title: String?
    
    @NSManaged var body: NSAttributedString?
    
    @NSManaged var mood: NSNumber?
    
    var moodEnum: DiaryEntryMood? {
        get {
            return DiaryEntryMood(rawValue: Int(self.mood!))
        }
        set {
            self.mood = newValue?.rawValue
        }
    }
}
