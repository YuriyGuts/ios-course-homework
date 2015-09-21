//
//  MasterViewController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 20.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, DiaryEntryEditedDelegate {
    
    var detailViewController: DetailViewController? = nil

    var diaryEntries = [DiaryEntry]()

    var dateDisplayFormatter = DateDisplayFormatter(settings: SettingsModel())

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSplitViewController()
        loadData()
    }

    func setUpSplitViewController() {
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func loadData() {
        diaryEntries.removeAll()
        
        diaryEntries.append(
            DiaryEntry(
                date: NSDate(),
                title: "Sunny Post",
                body: NSAttributedString(string: "I'm in an excellent mood right now."),
                mood: DiaryEntryMood.Sunny
            )
        )
        diaryEntries.append(
            DiaryEntry(
                date: NSDate(),
                title: "Cloudy Post",
                body: NSAttributedString(string: "My mood could have been better."),
                mood: DiaryEntryMood.Cloudy
            )
        )
        diaryEntries.append(
            DiaryEntry(
                date: NSDate(),
                title: "Rainy Post",
                body: NSAttributedString(string: "Today might just be the worst day of my life."),
                mood: DiaryEntryMood.Rainy
            )
        )
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
        let newEntry = DiaryEntry(
            date: NSDate(),
            title: "Title",
            body: NSAttributedString(string: "Body"),
            mood: DiaryEntryMood.Sunny
        )
        
        diaryEntries.insert(newEntry, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let diaryEntry = diaryEntries[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.diaryEntry = diaryEntry
                controller.delegate = self
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
        return diaryEntries.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let diaryEntry = diaryEntries[indexPath.row]
        cell.textLabel!.text = diaryEntry.title
        
        // TODO: Format this properly according to settings.
        cell.detailTextLabel!.text = dateDisplayFormatter.format(diaryEntry.date)
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            diaryEntries.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: - DiaryEntryEditedDelegate
    
    func diaryEntryEdited(diaryEntry: DiaryEntry) {
        tableView.reloadData()
    }
}

