//
//  PhotoAlbumCollectionViewFlowLayout.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit

@IBDesignable class PhotoAlbumCollectionViewFlowLayout : UICollectionViewFlowLayout {
	
	@IBInspectable var columns:UInt = 0 {
		didSet {
			itemSize = CGSizeMake(photoWidth, photoWidth)
		}
	}
	
	lazy var photoWidth:CGFloat = {
		let totalMargins = CGFloat(self.columns + 1) * self.minimumInteritemSpacing
		return (UIScreen.mainScreen().bounds.width - totalMargins) / CGFloat(self.columns)
		}()
}