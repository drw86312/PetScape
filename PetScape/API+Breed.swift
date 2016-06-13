//
//  API+Breed.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation

extension Endpoint {
	static func breeds(animal: Animal) -> Endpoint<[T]> {
		let parameters: [String: AnyObject] = ["animal" : animal.rawValue.lowercaseString]
		return Endpoint<[T]>(method: .GET,
		                     path: "breed.list",
		                     parameters: parameters,
		                     headers: nil,
		                     keyPath: API.baseKeyPath + ".breeds.breed")
	}
}
