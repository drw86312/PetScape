//
//  Sex.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

public enum Sex: String {
	case Male = "M"
	case Female = "F"
	case Unknown = "U"
	
	var titleString: String {
		switch self {
		case .Male:
			return "Male"
		case .Female:
			return "Female"
		case .Unknown:
			return "Unknown"
		}
	}
	
	static let all = [Male, Female, Unknown]
}

extension Sex: Decodable {
	public static func decode(json: JSON) -> Decoded<Sex> {
		return String.decode(json)
			.flatMap {
				return Sex(rawValue: $0.uppercaseString).map(pure) ?? .typeMismatch("Sex", actual: "String")
		}
	}
}