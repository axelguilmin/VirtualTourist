//
//  Pin+API.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/11/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit

extension Pin {
	
	// MARK: Var
	
	private struct AssociatedKeys {
		static var searchingTask = "searching"
	}
	
	var searchingTask: NSURLSessionDataTask? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.searchingTask) as? NSURLSessionDataTask
		}
		set {
			if let newValue = newValue {
				objc_setAssociatedObject(self, &AssociatedKeys.searchingTask, newValue as NSURLSessionDataTask?, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
			}
		}
	}
	
	var bbox:String {
		let halfDelta = 0.1
		let bottom_left_lon = max(self.longitude - halfDelta, -180)
		let bottom_left_lat = max(self.latitude - halfDelta, -90)
		let top_right_lon = min(self.longitude + halfDelta, 180)
		let top_right_lat = min(self.latitude + halfDelta, 90)
		return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
	}
	
	// MARK: API Calls
	
	func searchPhotoNearPin() {
		
		// Safety guard
		if self.searchingTask != nil && self.searchingTask?.state != .Completed {
			return
		}
		
		let params:[String : AnyObject] = [
			"safe_search": 1,
			"bbox": bbox,
			"content_type": 1,
			"per_page" : 40
		]
		
		self.searchingTask = FlickrAPI.get(
			method: "flickr.photos.search",
			param: params,
			success: {(status:Int, json:[String : AnyObject]?) -> () in
				if(status > 299) { // Request worked but the server responded with an error
					self.searchPhotoNearPinFailed()
					return
				}
				
				if let photos = json!["photos"] as? [String:AnyObject] {
					
					if let pages = photos["pages"] as? Int {
						
						var totalPhotosVal = 0
						if let totalPhotos = photos["total"] as? String {
							totalPhotosVal = (totalPhotos as NSString).integerValue
						}
						if totalPhotosVal > 0 {
							
							/* Flickr API - will only return up the 4000 images */
							var pageMax:Int = 4000 / (params["per_page"] as! Int)
							pageMax = min(pages, pageMax)
							let randomPage = Int(arc4random_uniform(UInt32(pageMax))) + 1
							
							println("searchPhotoNearPin - load page \(randomPage)/\(pages)")
							
							self.getImageFromFlickrBySearchWithPage(params, pageNumber: randomPage)
						}
						else {
							println("searchPhotoNearPin - This pin has no photo nearby")
							self.searchPhotoNearPinFailed()
						}
						
					} else {
						println("searchPhotoNearPin - Cant find key 'pages' in \(photos)")
						self.searchPhotoNearPinFailed()
					}
				} else {
					println("searchPhotoNearPin - Cant find key 'photos' in \(json)")
					self.searchPhotoNearPinFailed()
				}
			},
			failure: {
				println("searchPhotoNearPin - failure")
				self.searchPhotoNearPinFailed()
			}
		)
	}
	
	func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int) {
		
		/* Add the page to the method's arguments */
		var withPageDictionary = methodArguments
		withPageDictionary["page"] = pageNumber
		
		self.searchingTask = FlickrAPI.get(method: "flickr.photos.search",
			param: withPageDictionary,
			success: {(status:Int, json:[String : AnyObject]?) -> () in
				
				if(status > 299) { // Request worked but the server responded with an error
					self.searchPhotoNearPinFailed()
					return
				}
				
				if let photosDictionary = json!["photos"] as? [String:AnyObject] {
					
					if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
						
						dispatch_async(dispatch_get_main_queue()) {
							for info in photosArray {
								self.addPhoto(Photo(info, context:sharedContext))
							}
						}
						println("getImageFromFlickrBySearchWithPage - found \(photosArray.count) photos")
						CoreDataStackManager.sharedInstance().saveContext()
						self.searchingTask = nil
						
					} else {
						println("Cant find key 'photo' in \(photosDictionary)")
						self.searchPhotoNearPinFailed()
					}
				}
				else {
					println("Cant find key 'photos' in \(json)")
					self.searchPhotoNearPinFailed()
				}
			},
			failure:  {
				println("getImageFromFlickrBySearchWithPage - Do'h")
				self.searchPhotoNearPinFailed()
			}
		)
	}
	
	private func searchPhotoNearPinFailed() {
		self.searchingTask = nil
		NSNotificationCenter.defaultCenter().postNotificationName("noImageNotification", object: self, userInfo: nil)
	}
	
	override func prepareForDeletion() {
		super.prepareForDeletion()
		self.searchingTask?.cancel()
	}
}