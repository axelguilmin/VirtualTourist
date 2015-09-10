//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import MapKit

// MARK: Const

private let userDefaultMapPositionKey = "MapRegion"

class TravelLocationsMapViewController: ViewController, MKMapViewDelegate {

	// MARK: Outlet
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var tapToDeleteLabel: UILabel!
	@IBOutlet weak var editButton: UIBarButtonItem!
	
	// MARK: Layout
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		editing = false
		
		// Reload map position
		let userDefault = NSUserDefaults.standardUserDefaults()
		if let regionDict = userDefault.objectForKey(userDefaultMapPositionKey) as? Dictionary<String,CLLocationDegrees> {
			let region = MKCoordinateRegion(dictionary:regionDict)
			mapView.setRegion(region, animated: false)
		}
		
		// Detect long press to add a new pin
		let addPinGestureRecognzier = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
		mapView.addGestureRecognizer(addPinGestureRecognzier);
	}

	// MARK: IBAction
	
	@IBAction func edit(sender: UIBarButtonItem) {
		setEditing(!editing, animated: true)
	}
	
	// MARK: UIViewController
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showPhotoAlbum" {
			if let selectedAnnotation = mapView.selectedAnnotations.first as? MKAnnotation {
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
		// Ignore long press while editing
		if editing { return }
		
		switch(gestureRecognizer.state) {
		case .Began:
			let touchPoint = gestureRecognizer.locationInView(mapView)
			let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
			var annotation = MKPointAnnotation();
			annotation.coordinate = touchMapCoordinate
			mapView.addAnnotation(annotation)
			break
		default:
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
			pinView!.pinColor = .Red
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	// Respond to taps, opens the photo album VC
	func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
		if editing {
			mapView.removeAnnotation(view.annotation)
		}
		else {
			performSegueWithIdentifier("showPhotoAlbum", sender: self)
		}
	}
	
	func mapViewWillStartLoadingMap(mapView: MKMapView!) {
		
		// Save map position
		let userDefault = NSUserDefaults.standardUserDefaults()
		let regionDict = mapView.region.asDictionary()
		userDefault.setObject(regionDict, forKey: userDefaultMapPositionKey)
	}
}
