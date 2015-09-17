//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
	
	/// is the collection loading, loaded or empty
	private enum eStatus {
		case unknown
		case loading
		case loaded
		case empty
	}
	
	// MARK: Var
	
	var annotation: PinAnnotation!
	
	private var selectedCellsCount:Int {
		return collectionView.indexPathsForSelectedItems().count
	}
	
	private var status:eStatus = .unknown {
		didSet {
			dispatch_async(dispatch_get_main_queue()) {
				switch self.status {
				case .loading:
					let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
					indicator.startAnimating()
					self.collectionView.backgroundView = indicator
					
				case .loaded, .unknown:
					self.collectionView.backgroundView = nil
					
				case .empty:
					var label = UILabel()
					label.text = "This pin has no images."
					label.textAlignment = .Center
					self.collectionView.backgroundView = label
				}
			}
		}
	}
	
	// MARK: IBOutlet
	
	@IBOutlet private weak var mapView: MKMapView!
	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet private weak var toolbarButton: UIBarButtonItem!
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.allowsMultipleSelection = true
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if annotation != nil {
			let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
			let region = MKCoordinateRegion(center: annotation.coordinate, span:span)
			mapView.addAnnotation(annotation)
			mapView.setRegion(region, animated: false)
			mapView.regionThatFits(region)
			
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "noImage", name: "noImageNotification", object: annotation.pin)
		}
		
		fetchedResultsController.performFetch(nil)
		fetchedResultsController.delegate = self
	}
	
	func noImage() {
		self.status = .empty
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		fetchedResultsController.delegate = nil
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: IBAction
	
	@IBAction func newCollection(sender: UIBarButtonItem) {

		if(selectedCellsCount == 0) { // New collection
			if let photos = fetchedResultsController.fetchedObjects as? [Photo] {
				dispatch_async(dispatch_get_main_queue()) {
					for photo in photos {
						CoreDataStackManager.sharedInstance().delete(photo)
					}
				}
			}
			annotation.pin.searchPhotoNearPin()
			status = .loading
		}
			
		else { // Remove selected items
			for indexPath in collectionView.indexPathsForSelectedItems() as! [NSIndexPath] {
				let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
				CoreDataStackManager.sharedInstance().delete(photo)
			}
			CoreDataStackManager.sharedInstance().saveContext()
		}
	}
	
	// MARK: Private method
	
	private func layoutToolbar() {
		toolbarButton.title = selectedCellsCount > 0 ? "Remove Selected Pictures" : "New Collection"
	}
	
	// MARK: UICollectionViewDelegate
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		layoutToolbar()
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		layoutToolbar()
	}
	
	// MARK: UICollectionViewDataSource
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return fetchedResultsController.sections!.count
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
		if sectionInfo.numberOfObjects > 0 {
			status = .loaded
		}
		else {
			status = annotation.pin.searchingTask?.state != .Completed ? .loading : .empty
		}
		return sectionInfo.numberOfObjects
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
		
		// There is a case where the fetchedResultsController removed an object but the collectionView did not yet
		if fetchedResultsController.fetchedObjects?.count < indexPath.row {
			return cell
		}
		
		let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
		
		cell.image.image = nil
		cell.activityIndicator.startAnimating()
		NSNotificationCenter.defaultCenter().removeObserver(cell)
		
		if let cachedImage = photo.image {
			dispatch_async(dispatch_get_main_queue()) {
				cell.image.image = cachedImage
				cell.activityIndicator.stopAnimating()
			}
		}
		else {
			NSNotificationCenter.defaultCenter().addObserver(cell, selector: "imageLoaded:", name: Photo.imageLoadedNotification, object: photo)
		}
	
		return cell
	}
	
	// Mark: - Fetched Results Controller
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "Photo")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
		fetchRequest.predicate = NSPredicate(format: "pin == %@", self.annotation.pin);
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: sharedContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		return fetchedResultsController
		
		}()
	
	
	// MARK: - Fetched Results Controller Delegate
	
	// See https://stackoverflow.com/questions/26484073/how-to-insert-row-and-section-into-uicollectionview-at-same-time
	var insertItems = [NSIndexPath]()
	var deleteItems = [NSIndexPath]()
	var reloadItems = [NSIndexPath]()
	var moveItems = [(NSIndexPath,NSIndexPath)]()
	
	var insertSections: NSIndexSet?
	var deleteSections: NSIndexSet?
	var reloadSections: NSIndexSet?
	// TODO: section moved
	var controllerChanges = 0
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
//		println("controllerWillChangeContent")
	}
	
	func controller(controller: NSFetchedResultsController,
		didChangeObject anObject: AnyObject,
		atIndexPath indexPath: NSIndexPath?,
		forChangeType type: NSFetchedResultsChangeType,
		newIndexPath: NSIndexPath?) {
			
			switch(type) {
			case .Insert:
				insertItems.append(newIndexPath!)
				
			case .Delete:
				deleteItems.append(indexPath!)
				
			case .Update:
				reloadItems.append(indexPath!)
				
			case .Move:
				moveItems.append((indexPath!,newIndexPath!))
			}
	}
	
	func controller(controller: NSFetchedResultsController,
		didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
		atIndex sectionIndex: Int,
		forChangeType type: NSFetchedResultsChangeType) {
			
			switch(type) {
			case .Insert:
				insertSections = NSIndexSet(index: sectionIndex)
				
			case .Delete:
				deleteSections = NSIndexSet(index: sectionIndex)
				
			case .Update:
				reloadSections = NSIndexSet(index: sectionIndex)
				
			case .Move:
				break
				
			}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
//		println("controllerDidChangeContent")
		
		dispatch_async(dispatch_get_main_queue()) {
			CATransaction.begin()
			CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
			self.collectionView.performBatchUpdates({
				// Update cells
				self.collectionView.insertItemsAtIndexPaths(self.insertItems)
				
				self.collectionView.deleteItemsAtIndexPaths(self.deleteItems)
				self.collectionView.reloadItemsAtIndexPaths(self.reloadItems)
				for (from,to) in self.moveItems {
					self.collectionView.moveItemAtIndexPath(from, toIndexPath: to)
				}
				
				self.insertItems.removeAll()
				self.deleteItems.removeAll()
				self.reloadItems.removeAll()
				self.moveItems.removeAll()
				
				// Update sections
				if self.insertSections != nil {
					self.collectionView.insertSections(self.insertSections!)
				}
				if self.deleteSections != nil {
					self.collectionView.deleteSections(self.deleteSections!)
				}
				if self.reloadSections != nil {
					self.collectionView.reloadSections(self.reloadSections!)
				}
				
				self.insertSections = nil
				self.deleteSections = nil
				self.reloadSections = nil
				
				}, completion: { completed in
//					println("controllerDidChangeContent completion \(self.controllerChanges)")
					self.layoutToolbar()
			})
			CATransaction.commit()
		}
	}
}