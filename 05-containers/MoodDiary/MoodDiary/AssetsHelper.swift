//
//  AssetsHelper.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 22.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

class AssetsHelper {
    static func backgroundImageForMood(mood: DiaryEntryMood) -> UIImage? {
        var backgroundImageAssetID: String
        
        switch mood {
        case DiaryEntryMood.Cloudy:
            backgroundImageAssetID = "mood_cloudy_bg"
        case DiaryEntryMood.Rainy:
            backgroundImageAssetID = "mood_rainy_bg"
        default:
            backgroundImageAssetID = "mood_sunny_bg"
        }
        
        return UIImage(named: backgroundImageAssetID)
    }
    
    static func iconImageForMood(mood: DiaryEntryMood) -> UIImage? {
        var iconImageAssetID: String
        
        switch mood {
        case DiaryEntryMood.Cloudy:
            iconImageAssetID = "mood_cloudy_sm"
        case DiaryEntryMood.Rainy:
            iconImageAssetID = "mood_rainy_sm"
        default:
            iconImageAssetID = "mood_sunny_sm"
        }
        
        let image = UIImage(named: iconImageAssetID)
        if let unwrappedImage = image {
            return unwrappedImage.imageWithRenderingMode(.AlwaysTemplate)
        }
        return image
    }
    
    static func iconTintForMood(mood: DiaryEntryMood) -> UIColor {
        switch mood {
        case DiaryEntryMood.Cloudy:
            return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        case DiaryEntryMood.Rainy:
            return UIColor(red:0.373, green: 0.745, blue: 0.843, alpha: 1.0)
        default:
            return UIColor(red: 1.000, green: 0.643, blue: 0.455, alpha: 1.0)
        }
    }
}