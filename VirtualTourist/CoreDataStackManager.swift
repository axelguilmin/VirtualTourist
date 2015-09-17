//
//  CoreDataStackManager.swift
//
//  Created by Jason on 3/10/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"
private let MOMD_FILE_NAME = "VirtualTourist"

let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!

class CoreDataStackManager {
	
    // MARK: - Singleton
	
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
    
        return Static.instance
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
		
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
		
        let modelURL = NSBundle.mainBundle().URLForResource(MOMD_FILE_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
	
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        println("CoreDataStackManager sqlite path: \(url.path!)")
        
        var error: NSError? = nil

        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])

            // Left in for development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        println("CoreDataStackManager create managedObjectContext")

        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
		
		println("CoreDataStackManager saveContext")
		if let context = self.managedObjectContext {
			
			dispatch_async(dispatch_get_main_queue()) {
				var error: NSError? = nil

				if context.hasChanges && !context.save(&error) {
					NSLog("Unresolved error \(error), \(error!.userInfo)")
					abort()
				}
			}
		}
	}
	
	func delete(object:NSManagedObject) {
		// TODO: use NSBatchDeleteRequest on iOS9
		dispatch_async(dispatch_get_main_queue()) {
			sharedContext.deleteObject(object)
		}
	}
}