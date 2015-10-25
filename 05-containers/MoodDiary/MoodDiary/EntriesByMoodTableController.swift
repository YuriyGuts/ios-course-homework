//
//  EntriesByMoodTableController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 25.10.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import CoreData
import UIKit

class EntriesByMoodTableController: UITableViewController {

    private let _diaryEntryCellIdentifier = "DiaryEntryTableViewCell"
    
    private var _cachedDisplayedDiaryEntries: [PersistentDiaryEntry]?
    
    var moodToFilterBy: DiaryEntryMood? = nil
    
    var displayedDiaryEntries: [PersistentDiaryEntry] {
        if let _cachedDisplayedDiaryEntries = _cachedDisplayedDiaryEntries {
            return _cachedDisplayedDiaryEntries
        }
        return fetchDiaryEntries()
    }
    
    var managedObjectContext: NSManagedObjectContext? = nil {
        didSet {
            invalidateDisplayedDiaryEntries()
        }
    }
    
    var dateDisplayFormatter: DateDisplayFormatter? = nil
    
    var settingsChangedObserver: NSObjectProtocol? = nil

    var diaryEntryCreatedObserver: NSObjectProtocol? = nil

    var diaryEntryUpdatedObserver: NSObjectProtocol? = nil
    
    var diaryEntryDeletedObserver: NSObjectProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpDateDisplayFormatter()
        setUpNotificationObservers()
    }
    
    func setUpTableView() {
        // Enable auto row height adjustment.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
        // Register custom cells.
        let nib = UINib(nibName: _diaryEntryCellIdentifier, bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: _diaryEntryCellIdentifier)
    }
    
    func setUpDateDisplayFormatter() {
        if let settings = readSettingsFromAppDelegate() {
            dateDisplayFormatter = DateDisplayFormatter(settings: settings)
        }
    }
    
    func readSettingsFromAppDelegate() -> Settings? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.settings
    }
    
    func setUpNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        settingsChangedObserver = notificationCenter.addObserverForName(
            Notifications.SettingsChangedNotification,
            object: nil,
            queue: mainQueue,
            usingBlock: handleSettingsChangedNotification
        )
        
        diaryEntryCreatedObserver = notificationCenter.addObserverForName(
            Notifications.DiaryEntryCreatedNotification,
            object: nil,
            queue: mainQueue,
            usingBlock: handleDiaryEntryCreatedNotification
        )
        
        diaryEntryUpdatedObserver = notificationCenter.addObserverForName(
            Notifications.DiaryEntryUpdatedNotification,
            object: nil,
            queue: mainQueue,
            usingBlock: handleDiaryEntryUpdatedNotification
        )
        
        diaryEntryDeletedObserver = notificationCenter.addObserverForName(
            Notifications.DiaryEntryDeletedNotification,
            object: nil,
            queue: mainQueue,
            usingBlock: handleDiaryEntryDeletedNotification
        )
    }

    func handleDiaryEntryCreatedNotification(notification: NSNotification) {
        invalidateDisplayedDiaryEntries(animated: true)
    }
    
    func handleDiaryEntryUpdatedNotification(notification: NSNotification) {
        invalidateDisplayedDiaryEntries(animated: true)
    }
    
    func handleDiaryEntryDeletedNotification(notification: NSNotification) {
        invalidateDisplayedDiaryEntries(animated: true)
    }
    
    func handleSettingsChangedNotification(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, Settings>
        let newSettings = userInfo["newSettings"]!
        self.dateDisplayFormatter = DateDisplayFormatter(settings: newSettings)
        invalidateDisplayedDiaryEntries(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditEntryScreen" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let diaryEntry = displayedDiaryEntries[indexPath.row]
                let editEntryNavigationController = segue.destinationViewController as! UINavigationController
                let editEntryController = editEntryNavigationController.viewControllers[0] as! EditEntryViewController
                editEntryController.diaryEntry = diaryEntry
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDiaryEntries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(_diaryEntryCellIdentifier, forIndexPath: indexPath) as! DiaryEntryTableViewCell
        
        let diaryEntry = displayedDiaryEntries[indexPath.row]
        let displayTitle = (diaryEntry.title == nil || diaryEntry.title?.isEmpty == true)
            ? "(untitled)"
            : diaryEntry.title
        
        cell.moodImage?.image = AssetsHelper.iconImageForMood(diaryEntry.moodEnum!)
        cell.moodImage?.tintColor = AssetsHelper.iconTintForMood(diaryEntry.moodEnum!)
        cell.titleLabel?.text = displayTitle
        cell.dateLabel?.text = dateDisplayFormatter!.format(diaryEntry.date!)
        cell.bodyLabel?.text = diaryEntry.body?.string
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showEditEntryScreen", sender: self)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // MARK: - Table Data Manipulation
    
    func fetchDiaryEntries() -> [PersistentDiaryEntry] {
        guard
            let managedObjectContext = managedObjectContext,
            let fetchRequest = fetchRequestForDiaryEntries() else {
            return []
        }
        
        do {
            let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest)
            if let results = fetchResults as? [PersistentDiaryEntry] {
                _cachedDisplayedDiaryEntries = results
                return _cachedDisplayedDiaryEntries!
            }
        }
        catch let error as NSError {
            NSLog("Error while fetching data: \(error), \(error.userInfo)")
        }
        return []
    }
    
    func fetchRequestForDiaryEntries() -> NSFetchRequest? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("DiaryEntry", inManagedObjectContext: managedObjectContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if let moodToFilterBy = moodToFilterBy {
            fetchRequest.predicate = NSPredicate(format: "mood = %i", moodToFilterBy.rawValue)
        }
        
        return fetchRequest
    }
    
    func invalidateDisplayedDiaryEntries(animated animated: Bool = false) {
        _cachedDisplayedDiaryEntries = nil
        if animated {
            tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        } else {
            tableView?.reloadData()
        }
    }
    
    func displayedDiaryEntryAt(indexPath indexPath: NSIndexPath) -> PersistentDiaryEntry {
        return displayedDiaryEntries[indexPath.row]
    }
}