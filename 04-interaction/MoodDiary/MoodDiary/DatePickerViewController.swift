//
//  DatePickerViewController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 25.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    var delegate: DatePickerDelegate? = nil
    
    private var _backupDisplayedDate: NSDate = NSDate()
    
    var displayedDate: NSDate {
        // Supporting the case when the date picker is not yet loaded
        // so that the calling controller would be able to set
        // the date while preparing for the segue.
        get {
            if let datePicker = datePicker {
                return datePicker.date
            }
            else {
                return _backupDisplayedDate
            }
        }
        set {
            if let datePicker = datePicker {
                datePicker.date = newValue
            }
            else {
                _backupDisplayedDate = newValue
            }
        }
    }
    
    @IBOutlet weak var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker?.date = _backupDisplayedDate
    }
    
    override func viewWillAppear(animated: Bool) {
        // TODO: Well this is ugly :(
        self.preferredContentSize = CGSize(width: 350, height: 325)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        closePicker()
    }
    
    func closePicker() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = delegate {
            delegate.datePickerDidClose(pickedDate: displayedDate)
        }
    }
}
