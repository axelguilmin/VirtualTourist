//
//  Pin.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// TODO: This can be remove with xCode7
@objc(Pin)

class Pin: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var id: Int64
    @NSManaged var photos: NSManagedObject

	var coordinate:CLLocationCoordinate2D {
		get {
			return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		}
		set(value) {
			latitude = value.latitude
			longitude = value.longitude
		}
	}
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	convenience init(coordinate:CLLocationCoordinate2D, context: NSManagedObjectContext) {
		
		let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
		self.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.coordinate = coordinate
	}
}
