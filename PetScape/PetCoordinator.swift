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
	let locationManager: LocationManager
	
	init(locationManager: LocationManager) {
		self.locationManager = locationManager
		
		navigationController.navigationBar.defaultStyle = true
		petVC = StreamViewController(locationManager: locationManager,
		                             filterManager: filterManager)
		petVC.delegate = self
		reset()
	}
	
	func reset(animated: Bool = false) {
		navigationController.popToRootViewControllerAnimated(animated)
		navigationController.pushViewController(petVC, animated: animated)
	}
	
	func pushFiltersController() {
		
	}
}

extension PetCoordinator: StreamViewControllerDelegate {
	func filterIconPressed() {
		let vc = FilterListViewController(filterManager: filterManager,
		                                        locationManager: locationManager)
		vc.delegate = self
		navigationController.pushViewController(vc, animated: true)
	}
}

extension PetCoordinator: FilterListViewControllerDelegate {
	
	func rowSelected() {
		
	}
}
