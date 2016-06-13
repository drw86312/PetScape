//
//  Shelter.swift
//  PetScape
//
//  Created by David Warner on 6/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry

struct Shelter {
	let id: String
//	let name: String
}

extension Shelter: Decodable {
	static func decode(json: JSON) -> Decoded<Shelter> {
		let shelter = curry(Shelter.init)
			<^> json <| ["shelter", "id", "$t"]
//			<*> json <| ["$t"]
		return shelter
	}
}