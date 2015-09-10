//
//  MKCoordinateRegion.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
	func asDictionary() -> Dictionary<String,CLLocationDegrees> {
		return [
			"latitude" : self.center.latitude,
			"longitude" : self.center.longitude,
			"latitudeDelta" : self.span.latitudeDelta,
			"longitudeDelta" : self.span.longitudeDelta
		];
	}
	init(dictionary: Dictionary<String,CLLocationDegrees>) {
		self.center = CLLocationCoordinate2D(latitude: dictionary["latitude"]!, longitude: dictionary["longitude"]!)
		self.span = MKCoordinateSpan(latitudeDelta: dictionary["latitudeDelta"]!, longitudeDelta: dictionary["longitudeDelta"]!)
	}
}