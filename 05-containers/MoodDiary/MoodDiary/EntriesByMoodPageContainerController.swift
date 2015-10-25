//
//  EntriesByMoodPageContainerController.swift
//  MoodDiary
//
//  Created by Yuriy Guts on 25.10.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import CoreData
import UIKit

class EntriesByMoodPageContainerController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var _moodSpecificControllers: [UIViewController]? = nil
    
    private var _pageController: UIPageViewController? = nil
    
    var managedObjectContext: NSManagedObjectContext? = nil {
        didSet {
            if let _moodSpecificControllers = _moodSpecificControllers {
                for controller in _moodSpecificControllers as! [EntriesByMoodTableController] {
                    controller.managedObjectContext = managedObjectContext
                }
            }
        }
    }
    
    @IBAction func moodFilterChanged(sender: AnyObject) {
        guard
            let controllers = _moodSpecificControllers,
            let pageController = _pageController,
            let newMood = DiaryEntryMood(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        
        pageController.setViewControllers([controllers[newMood.rawValue]],
            direction: UIPageViewControllerNavigationDirection.Forward,
            animated: false,
            completion: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func controllerForPageWithMood(mood: DiaryEntryMood) -> EntriesByMoodTableController {
        if let moodTableViewController = storyboard?.instantiateViewControllerWithIdentifier("EntriesByMoodTableController") as? EntriesByMoodTableController {
            moodTableViewController.moodToFilterBy = mood
            moodTableViewController.managedObjectContext = managedObjectContext
            return moodTableViewController
        }
        return EntriesByMoodTableController()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPageControllerSegue" {
            if let destinationController = segue.destinationViewController as? UIPageViewController {
                var controllers = [
                    controllerForPageWithMood(.Sunny),
                    controllerForPageWithMood(.Cloudy),
                    controllerForPageWithMood(.Rainy),
                ]
                _moodSpecificControllers = controllers
                _pageController = destinationController
                
                destinationController.setViewControllers([controllers[0]],
                    direction: UIPageViewControllerNavigationDirection.Forward,
                    animated: false,
                    completion: nil
                )
            }
        }
    }
    
    // MARK: - Page View Controller
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let moodSpecificControllers = _moodSpecificControllers else {
            return nil
        }
        guard let controllerIndex = moodSpecificControllers.indexOf(viewController) else {
            return nil
        }
        
        if controllerIndex != moodSpecificControllers.first {
            return moodSpecificControllers[controllerIndex - 1]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let moodSpecificControllers = _moodSpecificControllers else {
            return nil
        }
        guard let controllerIndex = moodSpecificControllers.indexOf(viewController) else {
            return nil
        }
        
        if controllerIndex != moodSpecificControllers.last {
            return moodSpecificControllers[controllerIndex + 1]
        }

        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let moodSpecificControllers = _moodSpecificControllers else {
            return 0
        }
        return moodSpecificControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
}
