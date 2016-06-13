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
	
	var titleString: String {
		switch self {
		case .Available:
			return "Available"
		}
	}
}
