//
//  MoodDiaryTests.swift
//  MoodDiaryTests
//
//  Created by Yuriy Guts on 20.09.15.
//  Copyright © 2015 Yuriy Guts. All rights reserved.
//

import CoreData
import UIKit
import XCTest

@testable import MoodDiary

class PersistenceTests: XCTestCase {
    
    var managedObjectContext : NSManagedObjectContext? = nil
    
    // MARK: - Setup/Teardown
    
    override func setUp() {
        super.setUp()
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        setUpPersistentStoreCoordinator()
    }
    
    func setUpPersistentStoreCoordinator() {
        guard let modelURL = NSBundle(forClass: PersistenceTests.self).URLForResource("MoodDiaryModel", withExtension: "momd") else {
            XCTFail("Should be able to find momd")
            return
        }
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            XCTFail("Should be able to create managed object model")
            return
        }
        guard let moc = self.managedObjectContext else {
            XCTFail("Should be able to create managed object context")
            return
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let addResult = try? coordinator.addPersistentStoreWithType(
            NSInMemoryStoreType,
            configuration: nil,
            URL: nil,
            options: nil
        )
        
        if let _ = addResult  {
            moc.persistentStoreCoordinator = coordinator
        } else {
            XCTFail("Should be able to add in-memory store")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    func fetchAllDiaryEntries() -> [PersistentDiaryEntry] {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("DiaryEntry", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if let results = (try? self.managedObjectContext!.executeFetchRequest(fetchRequest)) as? [PersistentDiaryEntry] {
            return results
        }
        else {
            XCTFail("Should be able to fetch objects")
            return []
        }
    }
    
    func addEntityWithName(entityName: String, attributes: [String: AnyObject]? = nil) -> NSManagedObject {
        let item = NSEntityDescription.insertNewObjectForEntityForName(entityName,
            inManagedObjectContext: self.managedObjectContext!)
        
        if let attributes = attributes {
            for (key, value) in attributes {
                item.setValue(value, forKey: key)
            }
        }
        return item
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext!.save()
        }
        catch let error as NSError {
            XCTFail("Should be able to save MOC: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Tests
    
    func test_managedObjectContext_whenSavingEntities_shouldReturnSavedEntities() {
        // Arrange
        addEntityWithName(
            "DiaryEntry",
            attributes: [
                "date": NSDate(timeIntervalSince1970: NSTimeInterval(1443000000)),
                "title": "Sunny Post",
                "body": NSAttributedString(string: "I'm in an excellent mood right now."),
                "mood": 0,
            ]
        )
        addEntityWithName(
            "DiaryEntry",
            attributes: [
                "date": NSDate(timeIntervalSince1970: NSTimeInterval(1443000001)),
                "title": "Cloudy Post",
                "body": NSAttributedString(string: "My mood could have been better."),
                "mood": 1,
            ]
        )
        saveManagedObjectContext()
        
        // Act
        let fetchedEntries = fetchAllDiaryEntries()
        
        // Assert
        XCTAssertNotNil(fetchedEntries, "Should return non-nil fetch results with just inserted objects")
        XCTAssertEqual(fetchedEntries.count, 2, "Should return the same number of results that were inserted")
        XCTAssertEqual(fetchedEntries.first?.date, NSDate(timeIntervalSince1970: NSTimeInterval(1443000001)), "Should return the newer post first")
        XCTAssertEqual(fetchedEntries.first?.title, "Cloudy Post", "Should fetch the same title that was inserted")
        XCTAssertEqual(fetchedEntries.first?.mood, 1, "Should fetch the same mood that was inserted")
        XCTAssertEqual(fetchedEntries.first?.body, NSAttributedString(string: "My mood could have been better."), "Should fetch the same body that was inserted")
    }

    func test_managedObjectContext_whenDeletingEntities_shouldNotFetchThemAfterwards() {
        // Arrange
        let entry = addEntityWithName(
            "DiaryEntry",
            attributes: [
                "date": NSDate(timeIntervalSince1970: NSTimeInterval(1443000000)),
                "title": "Sunny Post",
                "body": NSAttributedString(string: "I'm in an excellent mood right now."),
                "mood": 0,
            ]
        )
        saveManagedObjectContext()
        
        // Act
        self.managedObjectContext!.deleteObject(entry)
        saveManagedObjectContext()
        let fetchedEntries = fetchAllDiaryEntries()
        
        // Assert
        XCTAssertEqual(fetchedEntries.count, 0, "Should no longer return the deleted entry")
    }
    
    func test_managedObjectContext_whenUpdatingEntities_shouldReturnUpdatedEntity() {
        // Arrange
        let entry = addEntityWithName(
            "DiaryEntry",
            attributes: [
                "date": NSDate(timeIntervalSince1970: NSTimeInterval(1443000000)),
                "title": "Sunny Post",
                "body": NSAttributedString(string: "I'm in an excellent mood right now."),
                "mood": 0,
            ]
        ) as! PersistentDiaryEntry
        saveManagedObjectContext()
        
        // Act
        entry.title = "[Updated] Sunny Post"
        saveManagedObjectContext()
        let fetchedResults = fetchAllDiaryEntries()
        
        // Assert
        XCTAssertEqual(fetchedResults.first?.title, "[Updated] Sunny Post")
    }
}
