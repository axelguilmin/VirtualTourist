//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import MapKit

class PinAnnotation: MKPointAnnotation {
	
	var pin:Pin! {
		didSet {
			coordinate = pin.coordinate
		}
	}

	convenience init(_ pin:Pin) {
		self.init()
		self.setValue(pin, forKey: "pin")
	}
}
