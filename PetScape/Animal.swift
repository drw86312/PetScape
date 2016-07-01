//
//  Animal.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

public enum Animal: String {
	case Barnyard = "Barnyard"
	case Bird = "Bird"
	case Cat = "Cat"
	case Dog = "Dog"
	case Horse = "Horse"
	case Pig = "Pig"
	case Reptile = "Scales, Fins & Other"
	case SmallFurry = "Small & Furry"
	
	// String values expected by the API
	var apiValue: String {
		switch self {
		case Barnyard, .Cat, .Bird, Dog, Horse, Pig:
		 return rawValue
		case Reptile:
			return "Reptile"
		case SmallFurry:
			return "SmallFurry"
		}
	}
	
	var titleString: String {
		switch self {
		case Barnyard, .Cat, .Bird, Dog, Horse, Pig, SmallFurry:
		 return rawValue
		case Reptile:
			return apiValue
		}
	}
}

extension Animal: Decodable {
	public static func decode(json: JSON) -> Decoded<Animal> {
		return String.decode(json)
			.flatMap {
				return Animal(rawValue: $0).map(pure) ?? .typeMismatch("Animal", actual: "String")
		}
	}
}