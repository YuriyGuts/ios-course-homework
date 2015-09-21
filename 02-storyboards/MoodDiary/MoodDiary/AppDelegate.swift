//
//  AppDelegate.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 20.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var settings: Settings? = nil

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        settings = Settings()
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let detailNavigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        
        let masterController = masterNavigationController.viewControllers[0] as! MasterViewController
        masterController.diaryEntries = loadDummyData()
        
        detailNavigationController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadDummyData() -> [DiaryEntry] {
        var diaryEntries = [DiaryEntry]()
        
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
        
        return diaryEntries
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.diaryEntry == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

