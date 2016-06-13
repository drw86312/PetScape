//
//  Age.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

public enum Age: String {
	case Baby = "BABY"
	case Young = "YOUNG"
	case Adult = "ADULT"
	case Senior = "SENIOR"
	
	var titleString: String {
		switch self {
		case .Baby:
			return "Baby"
		case .Young:
			return "Young"
		case .Adult:
			return "Adult"
		case .Senior:
			return "Senior"
		}
	}
}

extension Age: Decodable {
	public static func decode(json: JSON) -> Decoded<Age> {
		return String.decode(json)
			.flatMap {
				return Age(rawValue: $0.uppercaseString).map(pure) ?? .typeMismatch("Age", actual: "String")
		}
	}
}