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
	let name: String
	let latitude: Float
	let longitude: Float
	let contact: Contact
}

extension Shelter: Decodable {
	static func decode(json: JSON) -> Decoded<Shelter> {
		let shelter = curry(Shelter.init)
			<^> json <| ["id", "$t"]
			<*> json <| ["name" ,"$t"]
			<*> (json <| ["latitude" ,"$t"] >>- toFloat)
			<*> (json <| ["longitude" ,"$t"] >>- toFloat)
			<*> json <| []
		return shelter
	}
}