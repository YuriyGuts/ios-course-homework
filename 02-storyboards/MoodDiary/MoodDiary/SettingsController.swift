//
//  SettingsController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        closeScreen()
    }
    
    func closeScreen() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
