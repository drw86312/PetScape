//
//  Argo+Decode.swift
//  PetScape
//
//  Created by David Warner on 6/12/16.
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

extension NSURL: Decodable {
	public static func decode(json: JSON) -> Decoded<NSURL> {
		return String.decode(json)
			.flatMap {
				return NSURL(string: $0).map(pure) ?? .typeMismatch("NSURL", actual: "String")
		}
	}
}

extension Sex: Decodable {
	public static func decode(json: JSON) -> Decoded<Sex> {
		return String.decode(json)
			.flatMap {
				return Sex(rawValue: $0.uppercaseString).map(pure) ?? .typeMismatch("Sex", actual: "String")
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

extension Age: Decodable {
	public static func decode(json: JSON) -> Decoded<Age> {
		return String.decode(json)
			.flatMap {
				return Age(rawValue: $0.uppercaseString).map(pure) ?? .typeMismatch("Age", actual: "String")
		}
	}
}

func toInt(number: String) -> Decoded<Int> {
	return .fromOptional(Int(number))
}

func toBoolean(string: String) -> Decoded<Bool> {
	return .fromOptional(string.lowercaseString == "yes")
}

