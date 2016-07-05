//
//  FavoritesCoordinator.swift
//  PetScape
//
//  Created by David Warner on 7/5/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

class FavoritesCoordinator {
	
	let navigationController = UINavigationController()
	private(set) var favoritesVC: UIViewController!
	
	init() {
		navigationController.navigationBar.defaultStyle = true
		favoritesVC = UIViewController()
		reset()
	}
	
	func reset(animated: Bool = false) {
		navigationController.popToRootViewControllerAnimated(animated)
		navigationController.pushViewController(favoritesVC, animated: animated)
	}
	
}
