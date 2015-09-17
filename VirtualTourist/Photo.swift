//
//  Photo.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/11/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import CoreData

// TODO: This can be remove with xCode7
@objc(Photo)

class Photo: NSManagedObject {
	
	// MARK: Var

    @NSManaged var id: NSNumber
    @NSManaged var farm: NSNumber
    @NSManaged var height_m: NSNumber
    @NSManaged var isfamily: NSNumber
    @NSManaged var isfriend: NSNumber
    @NSManaged var ispublic: NSNumber
    @NSManaged var owner: String
    @NSManaged var secret: String
    @NSManaged var server: NSNumber
    @NSManaged var title: String
    @NSManaged var url_m: String
    @NSManaged var width_m: NSNumber
    @NSManaged var pin: Pin
	
	lazy var cacheIdentifier:String = {
		return "\(self.id)_\(self.secret)"
	}()
	
	// MARK: Lifecycle

	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	static var formatter:NSNumberFormatter = {
		let formatter = NSNumberFormatter()
		formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
		return formatter
		}()
	
	convenience init(_ info:[String:AnyObject], context: NSManagedObjectContext) {
		let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
		self.init(entity: entity, insertIntoManagedObjectContext: context)
		
		if (info.indexForKey("id") != nil) { id = Photo.formatter.numberFromString(info["id"] as! String)! } // What a hassle!
		if (info.indexForKey("farm") != nil) { farm = info["farm"] as! NSNumber }
		if (info.indexForKey("height_m") != nil) { height_m = Photo.formatter.numberFromString(info["height_m"] as! String)! }
		if (info.indexForKey("isfamily") != nil) { isfamily = info["isfamily"] as! Bool }
		if (info.indexForKey("isfriend") != nil) { isfriend = info["isfriend"] as! Bool }
		if (info.indexForKey("ispublic") != nil) { ispublic = info["ispublic"] as! Bool }
		if (info.indexForKey("owner") != nil) { owner = info["owner"] as! String }
		if (info.indexForKey("secret") != nil) { secret = info["secret"] as! String }
		if (info.indexForKey("server") != nil) { server = Photo.formatter.numberFromString(info["server"] as! String)! }
		if (info.indexForKey("title") != nil) { title = info["title"] as! String }
		if (info.indexForKey("url_m") != nil) { url_m = info["url_m"] as! String }
		if (info.indexForKey("width_m") != nil) { width_m = Photo.formatter.numberFromString(info["width_m"] as! String)! }
		if (info.indexForKey("pin") != nil) { pin = info["pin"] as! Pin }
	}
	
	override func prepareForDeletion() {
		super.prepareForDeletion()
		downloadTask?.cancel()
		
		// Passing nil will delete the cached file
		Photo.imageCache.storeImage(nil, withIdentifier: cacheIdentifier)
	}
	
	// MARK: Image
	
	static private let imageCache = ImageCache()
	static let imageLoadedNotification = "imageLoadedNotification"
	
	var image:UIImage? {
		get {
			if deleted {
				return nil // Don't download the image for a Photo that's just been deleted
			}
			if let cachedImage = Photo.imageCache.imageWithIdentifier(cacheIdentifier) {
				return cachedImage
			}
			else {
				downloadImage()
				return nil
			}
		}
	}
	
	private var downloadTask:NSURLSessionDataTask?

	private func downloadImage() {
		
		if downloadTask?.state == .Running {
			return // Already downloading
		}
		
		let request = NSURLRequest(URL: NSURL(string: url_m)!)
		let session = NSURLSession.sharedSession()
		downloadTask = session.dataTaskWithRequest(request) {[weak self] data, response, error in

			if error != nil || self == nil {
				return // Network error or Photo deleted
			}
			
			if let downloadedImage = UIImage(data: data) {
				println("↓ \(self!.url_m)")
				NSNotificationCenter.defaultCenter().postNotificationName(Photo.imageLoadedNotification, object: self, userInfo: ["image":downloadedImage])
				Photo.imageCache.storeImage(downloadedImage, withIdentifier:self!.cacheIdentifier)
			}
		}
	
		downloadTask!.resume()
	}
}

