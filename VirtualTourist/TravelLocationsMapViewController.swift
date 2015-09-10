//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: Const

private let USER_DEFAULT_MAP_POSITION_KEY = "MapRegion"

class TravelLocationsMapViewController: ViewController, MKMapViewDelegate {
	
	// MARK: Outlet
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var tapToDeleteLabel: UILabel!
	@IBOutlet weak var editButton: UIBarButtonItem!
	
	// MARK: Layout
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Not editing at first
		editing = false
		
		// Reload map position
		let userDefault = NSUserDefaults.standardUserDefaults()
		if let regionDict = userDefault.objectForKey(USER_DEFAULT_MAP_POSITION_KEY) as? Dictionary<String,CLLocationDegrees> {
			let region = MKCoordinateRegion(dictionary:regionDict)
			mapView.setRegion(region, animated: false)
		}
		
		// Detect long press to add a new pins
		let addPinGestureRecognzier = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
		mapView.addGestureRecognizer(addPinGestureRecognzier);
		
		// Load existing pins
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		fetchRequest.includesSubentities = false;
		if let pins = sharedContext.executeFetchRequest(fetchRequest, error:nil) as? [Pin] {
			for pin in pins {
				let annotation = PinAnnotation(pin);
				mapView.addAnnotation(annotation)
			}
		}
	}

	// MARK: IBAction
	
	@IBAction func edit(sender: UIBarButtonItem) {
		setEditing(!editing, animated: true)
	}
	
	// MARK: UIViewController
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showPhotoAlbum" {
			if let selectedAnnotation = mapView.selectedAnnotations.first as? PinAnnotation {
			let albumVC = segue.destinationViewController as! PhotoAlbumViewController
			albumVC.annotation = selectedAnnotation
			mapView.deselectAnnotation(selectedAnnotation, animated: true)
			}
		}
	}
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated:animated)
		
		tapToDeleteLabel.hidden = !editing
		editButton.title = editing ? "Done" : "Edit"
	}
	
	// MARK: Method
	
	func handleLongPress(gestureRecognizer:UIGestureRecognizer) {
		// Ignore long presses while editing
		if editing { return }
		
		struct Static {
			static var annotation:PinAnnotation?
		}
		
		switch(gestureRecognizer.state) {
		case .Began: // Create the annotation
			let touchPoint = gestureRecognizer.locationInView(mapView)
			let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
			Static.annotation = PinAnnotation();
			Static.annotation!.coordinate = touchMapCoordinate
			mapView.addAnnotation(Static.annotation)
			
		case .Changed: // Move it
			let touchPoint = gestureRecognizer.locationInView(mapView)
			let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
			Static.annotation!.coordinate = touchMapCoordinate
			
		case .Ended: // Save to CoreData
			let pin = Pin(coordinate: Static.annotation!.coordinate, context: sharedContext)
			Static.annotation!.pin = pin
			CoreDataStackManager.sharedInstance().saveContext()
			
		case .Cancelled: // Remove
			mapView.removeAnnotation(Static.annotation)
			Static.annotation = nil
			
		case .Failed: // Remove
			mapView.removeAnnotation(Static.annotation)
			Static.annotation = nil
			
		default: // Nothing
			break
		}
	}
	
	// MARK: MKMapViewDelegate
	
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		let reuseId = "pin"
		
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.animatesDrop = true
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	// Respond to taps, opens the photo album VC
	func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
		if editing {
			let annotation = view.annotation as! PinAnnotation
			sharedContext.deleteObject(annotation.pin)
			CoreDataStackManager.sharedInstance().saveContext()
			mapView.removeAnnotation(annotation)
		}
		else {
			performSegueWithIdentifier("showPhotoAlbum", sender: self)
		}
	}
	
	func mapViewWillStartLoadingMap(mapView: MKMapView!) {
		
		// Save map position
		let userDefault = NSUserDefaults.standardUserDefaults()
		let regionDict = mapView.region.asDictionary()
		userDefault.setObject(regionDict, forKey: USER_DEFAULT_MAP_POSITION_KEY)
	}
}
