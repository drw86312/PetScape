//
//  API+Pet.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation

extension Endpoint {
	
	static func getPet(petID: Int) -> Endpoint<T> {
		let parameters: [String: AnyObject] = ["id" : petID]
		return Endpoint<T>(method: .GET,
		                   path: "pet.get",
		                   parameters: parameters,
		                   headers: nil,
		                   keyPath: API.baseKeyPath + ".pet")
	}
	
	static func findPets(zip: String,
	                     animal: Animal? = nil,
	                     breed: String? = nil,
	                     size : Size? = nil,
	                     sex : Sex? = nil,
	                     age : Age? = nil,
	                     offset: Int = 0,
	                     count: Int = 20) -> Endpoint<[T]> {
		var parameters: [String: AnyObject] = ["location" : zip,
		                                       "offset" : offset,
		                                       "count" : count]
		if let animal = animal { parameters.addEntries(["animal" : animal.rawValue.lowercaseString]) }
		if let breed = breed { parameters.addEntries(["breed" : breed]) }
		if let size = size { parameters.addEntries(["size" : size.rawValue]) }
		if let sex = sex { parameters.addEntries(["sex" : sex.rawValue]) }
		if let age = age { parameters.addEntries(["age" : age.rawValue]) }
		return Endpoint<[T]>(method: .GET,
		                   path: "pet.find",
		                   parameters: parameters,
		                   headers: nil,
		                   keyPath: API.baseKeyPath + ".pets.pet")
	}
	
	static func getRandom() -> Endpoint<T> {
		let parameters: [String: AnyObject] = [:]
		return Endpoint<T>(method: .GET,
		                   path: "pet.getRandom",
		                   parameters: parameters,
		                   headers: nil,
		                   keyPath: API.baseKeyPath + ".pet")
	}
}
