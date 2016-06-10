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
		
		let endpoint = Endpoint<Pet>.random()
		API.fetch(endpoint) { result in
			print(result)
		}
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}


}

