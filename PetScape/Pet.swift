//
//  Pet.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry

struct Pet {
	let id: String
	let age: String
	let contact: Contact
}

extension Pet: Decodable {
	static func decode(json: JSON) -> Decoded<Pet> {
		let pet = curry(Pet.init)
			<^> json <| ["petfinder", "pet", "id", "$t"]
			<*> json <| ["petfinder", "pet", "age", "$t"]
			<*> json <| ["petfinder", "pet", "contact"]
		return pet
	}
}
