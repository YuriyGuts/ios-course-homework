//
//  MasterViewController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 20.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import CoreData
import UIKit

class MasterViewController: UITableViewController {
    
    private var _cachedDisplayedDiaryEntries: [PersistentDiaryEntry]?
    
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

    var detailViewController: DetailViewController? = nil
    
    var dateDisplayFormatter: DateDisplayFormatter? = nil
    
    var settingsChangedObserver: NSObjectProtocol? = nil
    
    var diaryEntryUpdatedObserver: NSObjectProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSplitViewController()
        setUpDateDisplayFormatter()
        setUpNotificationObservers()
    }
    
    func setUpSplitViewController() {
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
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
        
        diaryEntryUpdatedObserver = notificationCenter.addObserverForName(
            Notifications.DiaryEntryUpdatedNotification,
            object: nil,
            queue: mainQueue,
            usingBlock: handleDiaryEntryUpdatedNotification
        )
    }
    
    func handleDiaryEntryUpdatedNotification(notification: NSNotification) {
        saveManagedObjectContext()
        invalidateDisplayedDiaryEntries()
    }
    
    func handleSettingsChangedNotification(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, Settings>
        let newSettings = userInfo["newSettings"]!
        self.dateDisplayFormatter = DateDisplayFormatter(settings: newSettings)
        invalidateDisplayedDiaryEntries(animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createNewDiaryEntry(sender: AnyObject) {
        saveNewDiaryEntry()
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! SettingsViewController
            let settings = readSettingsFromAppDelegate()
            controller.loadSettingsObjectIntoUI(settings!)
        }
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let diaryEntry = displayedDiaryEntries[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.diaryEntry = diaryEntry
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let diaryEntry = displayedDiaryEntries[indexPath.row]
        let displayTitle = (diaryEntry.title == nil || diaryEntry.title?.isEmpty == true)
            ? "(untitled)"
            : diaryEntry.title

        cell.imageView?.image = AssetsHelper.iconImageForMood(diaryEntry.moodEnum!)
        cell.imageView?.tintColor = AssetsHelper.iconTintForMood(diaryEntry.moodEnum!)
        cell.textLabel!.text = displayTitle
        cell.detailTextLabel!.text = dateDisplayFormatter!.format(diaryEntry.date!)
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteDiaryEntryAt(indexPath: indexPath)
        }
    }
    
    // MARK: - Table Data Manipulation
    
    func fetchDiaryEntries() -> [PersistentDiaryEntry] {
        if let managedObjectContext = managedObjectContext {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("DiaryEntry", inManagedObjectContext: managedObjectContext)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
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
        }
        return []
    }
    
    func saveNewDiaryEntry() {
        if let managedObjectContext = managedObjectContext {
            if let newEntry = NSEntityDescription.insertNewObjectForEntityForName("DiaryEntry", inManagedObjectContext: managedObjectContext) as? PersistentDiaryEntry {
                newEntry.date = NSDate()
                newEntry.title = "(untitled)"
                newEntry.body = NSAttributedString(string: "")
                newEntry.moodEnum = DiaryEntryMood.Sunny
                saveManagedObjectContext()
                
                invalidateDisplayedDiaryEntries(animated: true)
            }
        }
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
    
    func deleteDiaryEntryAt(indexPath indexPath: NSIndexPath) {
        if let managedObjectContext = managedObjectContext {
            let diaryEntryToDelete = displayedDiaryEntryAt(indexPath: indexPath)
            managedObjectContext.deleteObject(diaryEntryToDelete)
            saveManagedObjectContext()
        }
        invalidateDisplayedDiaryEntries(animated: true)
    }
    
    func saveManagedObjectContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                }
                catch let errorDuringSave as NSError {
                    error = errorDuringSave
                    NSLog("Error while saving data: \(error), \(error!.userInfo)")
                }
            }
        }
    }
}
