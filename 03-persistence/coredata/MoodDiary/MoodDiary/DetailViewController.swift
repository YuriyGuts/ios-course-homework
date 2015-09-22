//
//  DetailViewController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 20.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var diaryEntryTitleEditor: UITextField?
    
    @IBOutlet weak var diaryEntryBodyEditor: UITextView?
    
    @IBOutlet weak var diaryEntryMoodEditor: UISegmentedControl?

    @IBOutlet weak var moodBackgroundView: UIImageView?
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem?
    
    var currentMood: DiaryEntryMood? {
        didSet {
            if let moodBackground = moodBackgroundView, mood = currentMood {
                moodBackground.image = AssetsHelper.backgroundImageForMood(mood)
                
                if let moodEditor = self.diaryEntryMoodEditor {
                    moodEditor.selectedSegmentIndex = (currentMood?.rawValue)!
                }
            }
        }
    }

    var diaryEntry: PersistentDiaryEntry? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let diaryEntry = self.diaryEntry {
            if let navigationTitle = navigationBarTitle {
                navigationTitle.title = diaryEntry.title
            }
            if let titleEditor = self.diaryEntryTitleEditor {
                titleEditor.text = diaryEntry.title
            }
            if let bodyEditor = self.diaryEntryBodyEditor {
                bodyEditor.attributedText = diaryEntry.body
            }
            currentMood = diaryEntry.moodEnum
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setUpEditors()
        self.configureView()
    }
    
    func setUpEditors() {
        if let bodyEditor = self.diaryEntryBodyEditor {
            bodyEditor.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func diaryEntryTitleEditingDidEnd(sender: UITextField) {
        if let navigationTitle = navigationBarTitle {
            navigationTitle.title = sender.text
        }
        
        if let diaryEntry = self.diaryEntry {
            diaryEntry.title = sender.text
            postDiaryEntryUpdatedNotification(diaryEntry)
        }
    }
    
    @IBAction func diaryEntryMoodChanged(sender: AnyObject) {
        let newMood = DiaryEntryMood(rawValue: sender.selectedSegmentIndex)
        currentMood = newMood
        
        if let diaryEntry = self.diaryEntry {
            diaryEntry.moodEnum = newMood
            postDiaryEntryUpdatedNotification(diaryEntry)
        }
    }

    func textViewDidChange(textView: UITextView) {
        if let diaryEntry = self.diaryEntry {
            diaryEntry.body = textView.attributedText
            postDiaryEntryUpdatedNotification(diaryEntry)
        }
    }
    
    func postDiaryEntryUpdatedNotification(diaryEntry: PersistentDiaryEntry) {
        // Post a notification so that the view controllers can update their views.
        NSNotificationCenter.defaultCenter().postNotificationName(
            Notifications.DiaryEntryUpdatedNotification,
            object: nil,
            userInfo: ["diaryEntry": diaryEntry]
        )
    }
}
