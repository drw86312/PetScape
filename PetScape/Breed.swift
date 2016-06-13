//
//  Breed.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry

struct Breed {
	let name: String
}

extension Breed: Decodable {
	static func decode(json: JSON) -> Decoded<Breed> {
		let breed = curry(Breed.init)
			<^> json <| ["$t"]
		return breed
	}
}