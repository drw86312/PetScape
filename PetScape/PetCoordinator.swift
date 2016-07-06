//
//  PetCoordinator.swift
//  PetScape
//
//  Created by David Warner on 7/5/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit


class PetCoordinator {
	
	let navigationController = UINavigationController()
	private(set) var petVC: StreamViewController!
	let filterManager = FilterManager()
	
	init(locationManager: LocationManager) {
		navigationController.navigationBar.defaultStyle = true
		petVC = StreamViewController(locationManager: locationManager,
		                             filterManager: filterManager)
		reset()
	}
	
	func reset(animated: Bool = false) {
		navigationController.popToRootViewControllerAnimated(animated)
		navigationController.pushViewController(petVC, animated: animated)
	}
}
