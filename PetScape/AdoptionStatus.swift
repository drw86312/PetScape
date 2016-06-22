//
//  AdoptionStatus.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

public enum AdoptionStatus: String {
	case Available = "A"
	case Hold = "H"
	case Pending = "P"
	case Unavailable = "X"
	
	var titleString: String {
		switch self {
		case .Available:
			return "Available"
		case .Hold:
			return "On Hold"
		case .Pending:
			return "Pending"
		case .Unavailable:
			return "Unavailable"
		}
	}
}

extension AdoptionStatus: Decodable {
	public static func decode(_ json: JSON) -> Decoded<AdoptionStatus> {
		return String.decode(json)
			.flatMap {
				return AdoptionStatus(rawValue: $0).map(pure) ?? .typeMismatch("Adoption Status", actual: "String")
		}
	}
}


