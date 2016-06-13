//
//  Argo+Decode.swift
//  PetScape
//
//  Created by David Warner on 6/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

extension NSURL: Decodable {
	public static func decode(json: JSON) -> Decoded<NSURL> {
		return String.decode(json)
			.flatMap {
				return NSURL(string: $0).map(pure) ?? .typeMismatch("NSURL", actual: "String")
		}
	}
}

func toInt(number: String) -> Decoded<Int> {
	return .fromOptional(Int(number))
}

func toFloat(number: String) -> Decoded<Float> {
	return .fromOptional(Float(number))
}

func toBoolean(string: String) -> Decoded<Bool> {
	return .fromOptional(string.lowercaseString == "yes")
}

func toNSDate(dateString: String) -> Decoded<NSDate> {
	let jsonDateFormatter: NSDateFormatter = {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		return dateFormatter
	}()
	return .fromOptional(jsonDateFormatter.dateFromString(dateString))
}
