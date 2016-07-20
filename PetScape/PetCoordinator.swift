//
//  PetCoordinator.swift
//  PetScape
//
//  Created by David Warner on 7/5/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

enum FilterField: String {
	case Animal = "Animal"
	case Breed = "Breed"
	case Size = "Size"
	case Sex = "Sex"
	case Age = "Age"
	case HasPhotos = "Has Photos?"
	
	static let all = [Animal, Breed, Size, Sex, Age, HasPhotos]
}

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
	
	func rowSelected(field: FilterField) {
		let vc = FilterSelectionViewController(field: field,
		                                       filterManager: filterManager)
		vc.delegate = self
		navigationController.pushViewController(vc, animated: true)
	}
}

extension PetCoordinator: FilterSelectionViewControllerDelegate {
	
	
}
