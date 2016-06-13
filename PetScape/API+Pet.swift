//
//  API+Pet.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation

extension Endpoint {
	
	static func pet(petID: Int) -> Endpoint<T> {
		let parameters: [String: AnyObject] = ["id" : petID]
		return Endpoint<T>(method: .GET,
		                   path: "pet.get",
		                   parameters: parameters,
		                   headers: nil,
		                   keyPath: API.baseKeyPath + ".pet")
	}
	
	
	static func random() -> Endpoint<T> {
		let parameters: [String: AnyObject] = [:]
		return Endpoint<T>(method: .GET,
		                   path: "pet.getRandom",
		                   parameters: parameters,
		                   headers: nil,
		                   keyPath: API.baseKeyPath + ".pet")
	}
	
	static func breeds(animal: Animal) -> Endpoint<[T]> {
		let parameters: [String: AnyObject] = ["animal" : animal.rawValue.lowercaseString]
		return Endpoint<[T]>(method: .GET,
		                     path: "breed.list",
		                     parameters: parameters,
		                     headers: nil,
		                     keyPath: API.baseKeyPath + ".breeds.breed")
	}
}
