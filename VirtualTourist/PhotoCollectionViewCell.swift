//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell : UICollectionViewCell {
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override var selected:Bool {
		didSet {
			image.alpha = selected ? 0.5 : 1.0
		}
	}
		
	func imageLoaded(notification: NSNotification) {

		if(self.image.image != nil) {
			println("Something smell fishy, this should never be executed")
			return
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			self.image.image = notification.userInfo!["image"] as? UIImage
			self.activityIndicator.stopAnimating()
		}
	}
}