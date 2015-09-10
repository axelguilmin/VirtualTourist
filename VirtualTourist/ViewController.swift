//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var showNavigationBar = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(!showNavigationBar, animated: animated)
	}
}

