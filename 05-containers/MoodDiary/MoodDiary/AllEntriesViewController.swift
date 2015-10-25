//
//  AllEntriesViewController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 20.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import CoreData
import UIKit

class AllEntriesViewController: UITableViewController {
    
    private let _diaryEntryCellIdentifier = "DiaryEntryTableViewCell"
    
    private var _cachedDisplayedDiaryEntries: [[PersistentDiaryEntry]]?
    
    var displayedDiaryEntries: [[PersistentDiaryEntry]] {
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
    
    var diaryEntryUpdatedObserver: NSObjectProtocol? = nil

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
        
        diaryEntryUpdatedObserver = notificationCenter.addObserverForName(
            Notifications.DiaryEntryUpdatedNotification,
            object: nil,
            queue: mainQueue,
            usingBlock: handleDiaryEntryUpdatedNotification
        )
    }
    
    func handleDiaryEntryUpdatedNotification(notification: NSNotification) {
        saveManagedObjectContext()
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

    @IBAction func createNewDiaryEntry(sender: AnyObject) {
        saveNewDiaryEntry()
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditEntryScreen" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let diaryEntry = displayedDiaryEntries[indexPath.section][indexPath.row]
                let editEntryController = segue.destinationViewController as! EditEntryViewController
                editEntryController.diaryEntry = diaryEntry
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return displayedDiaryEntries.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDiaryEntries[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if displayedDiaryEntries[section].count == 0 {
            return nil
        }
        
        switch section {
        case 1:
            return "This Week"
        case 2:
            return "Earlier"
        default:
            return "Today"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(_diaryEntryCellIdentifier, forIndexPath: indexPath) as! DiaryEntryTableViewCell

        let diaryEntry = displayedDiaryEntries[indexPath.section][indexPath.row]
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
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteDiaryEntryAt(indexPath: indexPath)
        }
    }
    
    // MARK: - Table Data Manipulation
    
    func fetchDiaryEntries() -> [[PersistentDiaryEntry]] {
        if let managedObjectContext = managedObjectContext {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("DiaryEntry", inManagedObjectContext: managedObjectContext)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            do {
                let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest)
                if let results = fetchResults as? [PersistentDiaryEntry] {
                    _cachedDisplayedDiaryEntries = diaryEntriesOrganizedIntoDateCategories(results)
                    return _cachedDisplayedDiaryEntries!
                }
            }
            catch let error as NSError {
                NSLog("Error while fetching data: \(error), \(error.userInfo)")
            }
        }
        return []
    }
    
    func diaryEntriesOrganizedIntoDateCategories(entries: [PersistentDiaryEntry], referenceDate: NSDate=NSDate()) -> [[PersistentDiaryEntry]] {
        let todayBeginningDate = referenceDate.beginningOfDay()!
        let thisWeekBeginningDate = referenceDate.beginningOfWeek()!
        
        return [
            entries.filter({ $0.date >= todayBeginningDate }),
            entries.filter({ $0.date >= thisWeekBeginningDate && $0.date < todayBeginningDate }),
            entries.filter({ $0.date < thisWeekBeginningDate })
        ]
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
            tableView?.reloadSections(
                NSIndexSet(indexesInRange: NSRange(location: 0, length: displayedDiaryEntries.count)),
                withRowAnimation: .Automatic
            )
        } else {
            tableView?.reloadData()
        }
    }
    
    func displayedDiaryEntryAt(indexPath indexPath: NSIndexPath) -> PersistentDiaryEntry {
        return displayedDiaryEntries[indexPath.section][indexPath.row]
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
