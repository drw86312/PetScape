//
//  BaseViewController.swift
//  PetScape
//
//  Created by David Warner on 5/17/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
//		let random = Endpoint<Pet>.random()
//		API.fetch(random) { result in
//			print(result)
//		}
		
		let shelter = Endpoint<Shelter>.findShelters("60606")
		API.fetch(shelter) { result in
			print(result)
		}
		
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

