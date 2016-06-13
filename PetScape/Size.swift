//
//  Size.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

public enum Size: String {
	case Small = "S"
	case Medium = "M"
	case Large = "L"
	case ExtraLarge = "XL"
	
	var titleString: String {
		switch self {
		case .Small:
			return "Small"
		case .Medium:
			return "Medium"
		case .Large:
			return "Large"
		case .ExtraLarge:
			return "Extra Large"
		}
	}
}

extension Size: Decodable {
	public static func decode(json: JSON) -> Decoded<Size> {
		return String.decode(json)
			.flatMap {
				return Size(rawValue: $0.uppercaseString).map(pure) ?? .typeMismatch("Size", actual: "String")
		}
	}
}