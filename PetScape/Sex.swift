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
	
	var titleString: String {
		switch self {
		case .Male:
			return "Male"
		case .Female:
			return "Female"
		}
	}
}

extension Sex: Decodable {
	public static func decode(_ json: JSON) -> Decoded<Sex> {
		return String.decode(json)
			.flatMap {
				return Sex(rawValue: $0.uppercased()).map(pure) ?? .typeMismatch("Sex", actual: "String")
		}
	}
}
