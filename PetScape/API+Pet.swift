//
//  API+Pet.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation

extension Endpoint {
	static func random() -> Endpoint<T> {
		let parameters: [String: AnyObject] = [:]
		return Endpoint<T>(method: .GET,
		                     path: "pet.getRandom",
		                     parameters: parameters,
		                     headers: nil)
	}
}
