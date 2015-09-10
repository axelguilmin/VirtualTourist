//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	// MARK: Var
	
	var annotation: PinAnnotation!
	
	// MARK: IBOutlet
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: Life Cycle
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if annotation != nil {
			let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
			let region = MKCoordinateRegion(center: annotation.coordinate, span:span)
			mapView.addAnnotation(annotation)
			mapView.setRegion(region, animated: false)
			mapView.regionThatFits(region)
		}
		
		collectionView.allowsMultipleSelection = true
	}
	
	// MARK: IBAction
	
	@IBAction func newCollection(sender: UIBarButtonItem) {
		// TODO:
	}
	
	// MARK: UICollectionViewDelegate
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let cell =	collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
		
		// TODO:
	}
	
	// MARK: UICollectionViewDataSource
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// TODO:
		return 42;
	}
	
	// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as? PhotoCollectionViewCell

		// TODO:
		
		return cell!
	}
	
	
}