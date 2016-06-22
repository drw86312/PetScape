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
	case Reptile = "Reptile"
	case SmallFurry = "SmallFurry"
}

extension Animal: Decodable {
	public static func decode(_ json: JSON) -> Decoded<Animal> {
		return String.decode(json)
			.flatMap {
				return Animal(rawValue: $0).map(pure) ?? .typeMismatch("Animal", actual: "String")
		}
	}
}
