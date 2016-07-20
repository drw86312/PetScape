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
	case Baby = "Baby"
	case Young = "Young"
	case Adult = "Adult"
	case Senior = "Senior"
	
	var titleString: String {
		return rawValue
	}
	
	static let all = [Baby, Young, Adult, Senior]
}

extension Age: Decodable {
	public static func decode(json: JSON) -> Decoded<Age> {
		return String.decode(json)
			.flatMap {
				return Age(rawValue: $0).map(pure) ?? .typeMismatch("Age", actual: "String")
		}
	}
}
