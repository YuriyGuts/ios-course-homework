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
    
    var currentMood: DiaryEntryMood? {
        didSet {
            if let moodBackground = moodBackgroundView, mood = currentMood {
                var backgroundImageAssetID: String
                
                switch mood {
                case DiaryEntryMood.Cloudy:
                    backgroundImageAssetID = "mood_cloudy_bg"
                case DiaryEntryMood.Rainy:
                    backgroundImageAssetID = "mood_rainy_bg"
                default:
                    backgroundImageAssetID = "mood_sunny_bg"
                }
                
                moodBackground.image = UIImage(named: backgroundImageAssetID)
                
                if let moodEditor = self.diaryEntryMoodEditor {
                    moodEditor.selectedSegmentIndex = (currentMood?.rawValue)!
                }
            }
        }
    }

    var diaryEntry: DiaryEntry? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var delegate: DiaryEntryEditedDelegate?

    func configureView() {
        // Update the user interface for the detail item.
        if let diaryEntry = self.diaryEntry {
            if let titleEditor = self.diaryEntryTitleEditor {
                titleEditor.text = diaryEntry.title
            }
            if let bodyEditor = self.diaryEntryBodyEditor {
                bodyEditor.attributedText = diaryEntry.body
            }
            currentMood = diaryEntry.mood
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
        if let diaryEntry = self.diaryEntry {
            diaryEntry.title = sender.text
            if let delegate = self.delegate {
                delegate.diaryEntryEdited(diaryEntry)
            }
        }
    }
    
    @IBAction func diaryEntryMoodChanged(sender: AnyObject) {
        let newMood = DiaryEntryMood(rawValue: sender.selectedSegmentIndex)
        currentMood = newMood
        
        if let diaryEntry = self.diaryEntry {
            diaryEntry.mood = newMood
            if let delegate = self.delegate {
                delegate.diaryEntryEdited(diaryEntry)
            }
        }
    }

    func textViewDidChange(textView: UITextView) {
        if let diaryEntry = self.diaryEntry {
            diaryEntry.body = textView.attributedText
            if let delegate = self.delegate {
                delegate.diaryEntryEdited(diaryEntry)
            }
        }
    }
}
