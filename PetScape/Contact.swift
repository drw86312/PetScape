//
//  Contact.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry

struct Contact {
	let address1: String?
	let address2: String?
	let city: String?
	let email: String?
	let fax: String?
	let phone: String?
	let state: String?
	let country: String?
	let zip: String?
}

extension Contact: Decodable {
	static func decode(json: JSON) -> Decoded<Contact> {
		let contact = curry(Contact.init)
			<^> json <|? ["address1", "$t"]
			<*> json <|? ["address2", "$t"]
			<*> json <|? ["city", "$t"]
			<*> json <|? ["email", "$t"]
			<*> json <|? ["fax", "$t"]
			<*> json <|? ["phone", "$t"]
			<*> json <|? ["state", "$t"]
			<*> json <|? ["country", "$t"]
			<*> json <|? ["zip", "$t"]
		return contact
	}
}