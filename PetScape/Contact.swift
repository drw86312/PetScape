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
		return contact
			<*> json <|? ["state", "$t"]
			<*> json <|? ["country", "$t"]
			<*> json <|? ["zip", "$t"]
	}
}

extension Contact {
	
	func formatted(withLineBreaks: Bool) -> String {
		return withLineBreaks ?
			formatWithLineBreaks(address1, address2: address2, city: city, state: state, country: country, zip: zip) :
			formatWithoutLineBreaks(address1, address2: address2, city: city, state: state, country: country, zip: zip)
	}
	
	// Formats an address from optional components with line breaks
	private func formatWithLineBreaks(address1: String? = nil,
	                            address2: String? = nil,
	                            city: String? = nil,
	                            state: String? = nil,
	                            country: String? = nil,
	                            zip: String? = nil) -> String {
		
		var accum: String = ""
		
		var line1 = address1 ?? ""
		let address2 = address2 ?? ""
		if address2.characters.count > 0 { line1 += ", " + address2 } else { line1 += address2 }
		
		accum = line1
		if accum.characters.count > 0 { accum += "\n" }
		
		var line2 = city ?? ""
		let state = state ?? ""
		if state.characters.count > 0 { line2 += ", " + state } else { line2 += state }
		
		accum += line2
		if accum.characters.count > 0 { accum += "\n" }
		
		var line3 = country ?? ""
		let zip = zip ?? ""
		if zip.characters.count > 0 { line3 += " " + zip } else { line3 += zip }
		
		accum += line3
		return accum
	}
	
	// Formats an address from optional components with line breaks
	private func formatWithoutLineBreaks(address1: String? = nil,
	                                  address2: String? = nil,
	                                  city: String? = nil,
	                                  state: String? = nil,
	                                  country: String? = nil,
	                                  zip: String? = nil) -> String {
		
		var accum: String = ""
		
		var line1 = address1 ?? ""
		let address2 = address2 ?? ""
		if address2.characters.count > 0 { line1 += ", " + address2 } else { line1 += address2 }
		
		accum = line1
		if accum.characters.count > 0 { accum += " " }
		
		var line2 = city ?? ""
		let state = state ?? ""
		if state.characters.count > 0 { line2 += ", " + state } else { line2 += state }
		
		accum += line2
		if accum.characters.count > 0 { accum += ", " }
		
		var line3 = country ?? ""
		let zip = zip ?? ""
		if zip.characters.count > 0 { line3 += " " + zip } else { line3 += zip }
		
		accum += line3
		return accum
	}
}
