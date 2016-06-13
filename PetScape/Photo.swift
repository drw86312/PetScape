//
//  Photo.swift
//  PetScape
//
//  Created by David Warner on 6/11/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry

struct Photo {
	let id: String
	let url: NSURL
}

extension Photo: Decodable {
	static func decode(json: JSON) -> Decoded<Photo> {
		let photo = curry(Photo.init)
			<^> json <| ["@id"]
			<*> json <| ["$t"]
		return photo
	}
}
