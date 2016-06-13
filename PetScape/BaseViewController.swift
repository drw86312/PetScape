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
		
		//		let endpoint = Endpoint<Shelter>.shelters("60606")
		// let endpoint = Endpoint<Breed>.breeds(.Reptile)
		let endpoint = Endpoint<Pet>.pet(34725116)
//		 let endpoint = Endpoint<Pet>.random()
		
		API.fetch(endpoint) { response in
			switch response.result {
			case .Success(let pet):
				print(pet)
			case .Failure(let error):
				print(error)
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

