//
//  Pet.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry
import Foundation

struct Pet {
	let id: Int
	let description: String?
	let mix: Bool?
	let animal: Animal?
	let age: Age?
	let sex: Sex?
	let size: Size?
	let contact: Contact
	let photos: [Photo]?
	let name: String?
	
	// Options are keyword descriptors (ex. "hasShots", "housetrained", "specialNeeds", etc.)
	let options: [String]?
	
	let shelterID: String?
	let shelterPetID: String?
	//	let breeds: [String]?
}

extension Pet: Decodable {
	
	static func decode(json: JSON) -> Decoded<Pet> {
		let pet = curry(Pet.init)
			<^> (json <| ["id", "$t"] >>- toInt)
			<*> json <|? ["description", "$t"]
			<*> (json <| ["mix", "$t"] >>- toBoolean)
			<*> json <|? ["animal", "$t"]
			<*> json <|? ["age", "$t"]
			<*> json <|? ["sex", "$t"]
			<*> json <|? ["size", "$t"]
			<*> json <| ["contact"]
			<*> json <||? ["media", "photos", "photo"]
			<*> json <|? ["name", "$t"]
			<*> json <||? ["options", "option"]
			<*> json <|? ["shelterId", "$t"]
			<*> json <|? ["shelterPetId", "$t"]
		//			<*> json <||? ["petfinder", "pet", "breeds"]
		return pet
	}
}
