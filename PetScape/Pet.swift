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
	let age: Age?
	let sex: Sex?
	let size: Size?
	let contact: Contact
	let photos: [Photo]?
	let name: String?
//	let breeds: [String]?
}

extension Pet: Decodable {
	
	static func decode(json: JSON) -> Decoded<Pet> {
		let pet = curry(Pet.init)
			<^> (json <| ["petfinder", "pet", "id", "$t"] >>- toInt)
			<*> json <|? ["petfinder", "pet", "description", "$t"]
			<*> (json <| ["petfinder", "pet", "mix", "$t"] >>- toBoolean)
			<*> json <|? ["petfinder", "pet", "age", "$t"]
			<*> json <|? ["petfinder", "pet", "sex", "$t"]
			<*> json <|? ["petfinder", "pet", "size", "$t"]
			<*> json <| ["petfinder", "pet", "contact"]
			<*> json <||? ["petfinder", "pet", "media", "photos", "photo"]
			<*> json <|? ["petfinder", "pet", "name", "$t"]
//			<*> json <||? ["petfinder", "pet", "breeds"]
		return pet
	}
}
