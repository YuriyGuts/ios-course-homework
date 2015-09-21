//
//  SettingsModel.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import Foundation

class SettingsModel {
    
    var includeTime: Bool
    
    var useRelativeDates: Bool
    
    init(includeTime: Bool=true, useRelativeDates: Bool=true) {
        self.includeTime = includeTime
        self.useRelativeDates = useRelativeDates
    }
    
}
