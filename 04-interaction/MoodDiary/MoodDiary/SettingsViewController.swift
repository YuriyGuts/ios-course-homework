//
//  SettingsController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 21.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var selectedIndexPath: NSIndexPath? = nil
    
    var settingsToLoadInitially: Settings? = nil
    
    @IBOutlet weak var dateFormatDateAndTimeCell: UITableViewCell?
    
    @IBOutlet weak var dateFormatDateOnlyCell: UITableViewCell?
    
    @IBOutlet weak var useRelativeDatesSwitch: UISwitch?

    @IBOutlet weak var datePreviewLabel: UILabel?
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        saveSettings()
        closeScreen()
    }
    
    @IBAction func useRelativeDatesSwitchChanged(sender: UISwitch) {
        updateDatePreview()
    }
    
    func saveSettings() {
        let newSettings = createSettingsObjectFromUI()
        
        // Save new settings to App Delegate.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.settings = newSettings
        
        // Post a notification so that the view controllers can update their views.
        NSNotificationCenter.defaultCenter().postNotificationName(
            Notifications.SettingsChangedNotification,
            object: nil,
            userInfo: ["newSettings": newSettings]
        )
    }
    
    func closeScreen() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell.accessoryType = indexPath == selectedIndexPath
                ? UITableViewCellAccessoryType.Checkmark
                : UITableViewCellAccessoryType.None
            updateDatePreview()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            selectedIndexPath = indexPath
            tableView.reloadData()
        }
    }
    
    func updateDatePreview() {
        if let previewLabel = datePreviewLabel {
            let dateToDisplay = NSDate().beginningOfDay()
            let previewDateFormatter = DateDisplayFormatter(settings: createSettingsObjectFromUI())
            previewLabel.text = previewDateFormatter.format(dateToDisplay!)
        }
    }
    
    func loadSettingsObjectIntoUI(settings: Settings) {
        selectedIndexPath = NSIndexPath(forRow: settings.includeTime ? 0 : 1, inSection: 0)
        tableView.reloadData()
        
        if let relativeDatesSwitch = useRelativeDatesSwitch {
            relativeDatesSwitch.on = settings.useRelativeDates
        }
        
        updateDatePreview()
    }
    
    func createSettingsObjectFromUI() -> Settings {
        if let relativeDatesSwitch = useRelativeDatesSwitch, dateAndTimeCell = dateFormatDateAndTimeCell {
            return Settings(
                includeTime: dateAndTimeCell.accessoryType == UITableViewCellAccessoryType.Checkmark,
                useRelativeDates: relativeDatesSwitch.on
            )
        }
        return Settings()
    }
}
