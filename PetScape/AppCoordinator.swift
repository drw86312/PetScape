//
//  AppCoordinator.swift
//  PetScape
//
//  Created by David Warner on 7/5/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

class AppCoordinator {
	
	let locationManager = LocationManager()
	
	private(set) var baseVC: UITabBarController!
	
	let petCoordinator: PetCoordinator
	let shelterCoordinator: ShelterCoordinator
	let favoritesCoordinator: FavoritesCoordinator
	
	init(window: UIWindow) {
		
		window.backgroundColor = UIColor.whiteColor()
		
		baseVC = UITabBarController()
		
		petCoordinator = PetCoordinator(locationManager: locationManager)
		shelterCoordinator = ShelterCoordinator()
		favoritesCoordinator = FavoritesCoordinator()
				
		baseVC.viewControllers = [petCoordinator.navigationController,
								  shelterCoordinator.navigationController,
								  favoritesCoordinator.navigationController]
		baseVC.tabBar.defaultStyle = true
	}
	
	func start() {

	}
	
}
