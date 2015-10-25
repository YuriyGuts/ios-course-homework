//
//  SettingsChangedDelegate.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

class Notifications {
    private static let prefix: String = NSBundle.mainBundle().bundleIdentifier! + ".notifications."
    
    static let SettingsChangedNotification = Notifications.prefix + "SettingsChangedNotification"
    
    static let DiaryEntryCreatedNotification = Notifications.prefix + "DiaryEntryCreatedNotification"
    
    static let DiaryEntryUpdatedNotification = Notifications.prefix + "DiaryEntryUpdatedNotification"
    
    static let DiaryEntryDeletedNotification = Notifications.prefix + "DiaryEntryDeletedNotification"
}
