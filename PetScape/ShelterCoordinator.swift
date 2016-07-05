//
//  ShelterCoordinator.swift
//  PetScape
//
//  Created by David Warner on 7/5/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit


class ShelterCoordinator {
	
	let navigationController = UINavigationController()
	private(set) var shelterVC: UIViewController!
	
	init() {
		navigationController.navigationBar.defaultStyle = true
		shelterVC = UIViewController()
		reset()
	}
	
	func reset(animated: Bool = false) {
		navigationController.popToRootViewControllerAnimated(animated)
		navigationController.pushViewController(shelterVC, animated: animated)
	}
}
