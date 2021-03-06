//
//  API+Shelter.swift
//  PetScape
//
//  Created by David Warner on 6/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation

extension Endpoint {
	
	static func getShelter(_ shelterID: String) -> Endpoint<T> {
		return Endpoint<T>(method: .GET,
		                   path: "shelter.get",
		                   parameters: ["id" : shelterID],
		                   headers: nil,
		                   keyPath: API.baseKeyPath + ".shelter")
	}
	
	static func findShelters(_ zip: String,
	                         shelterName: String? = nil,
	                         offset: Int = 0,
	                         count: Int = 20) -> Endpoint<[T]> {
		var parameters: [String: AnyObject] = ["location" : zip,
		                                       "offset" : offset,
		                                       "count" : count]
		if let shelterName = shelterName {
			parameters.addEntries(["name" : shelterName])
		}
		return Endpoint<[T]>(method: .GET,
		                     path: "shelter.find",
		                     parameters: parameters,
		                     headers: nil,
		                     keyPath: API.baseKeyPath + ".shelters.shelter")
	}
	
	static func findPetsForShelter(_ shelterID: String,
	                               offset: Int = 0,
	                               count: Int = 20,
	                               adoptionStatus: AdoptionStatus? = nil) -> Endpoint<[T]> {
		var parameters: [String: AnyObject] = ["id" : shelterID,
		                                       "offset" : offset,
		                                       "count" : count]
		if let adoptionStatus = adoptionStatus { parameters.addEntries(["status" : adoptionStatus.rawValue]) }
		return Endpoint<[T]>(method: .GET,
		                     path: "shelter.getPets",
		                     parameters: parameters,
		                     headers: nil,
		                     keyPath: API.baseKeyPath + ".pets.pet")
	}
}
