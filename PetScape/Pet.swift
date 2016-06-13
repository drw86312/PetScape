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
	let lastUpdated: NSDate?
	let mix: Bool?
	let description: String?
	let animal: Animal?
	let age: Age?
	let sex: Sex?
	let size: Size?
	let contact: Contact?
	let photos: [Photo]?
	let name: String?
	let shelterID: String?
	let shelterPetID: String?
}

extension Pet: Decodable {
	static func decode(json: JSON) -> Decoded<Pet> {
		let partialPet = curry(Pet.init)
			<^> (json <| ["id", "$t"] >>- toInt)
			<*> (json <| ["lastUpdate", "$t"] >>- toNSDate)
			<*> (json <| ["mix", "$t"] >>- toBoolean)
			<*> json <|? ["description", "$t"]
			<*> json <|? ["animal", "$t"]
			<*> json <|? ["age", "$t"]
			<*> json <|? ["sex", "$t"]
			<*> json <|? ["size", "$t"]
			<*> json <|? ["contact"]
			<*> json <||? ["media", "photos", "photo"]
		return partialPet
			<*> json <|? ["name", "$t"]
			<*> json <|? ["shelterId", "$t"]
			<*> json <|? ["shelterPetId", "$t"]
	}
}

// Options are keyword descriptors (ex. "hasShots", "housetrained", "specialNeeds", etc.)
//	let options: [String]?
//	let breeds: [String]?

//			<*> json <||? ["options", "option"]
//			<*> json <||? ["petfinder", "pet", "breeds"]
