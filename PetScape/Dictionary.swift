//
//  Dictionary.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

extension Dictionary {
	internal mutating func addEntries(other: [Key:Value]) {
		for (key, value) in other {
			self[key] = value
		}
	}
	
	internal func withEntries(other: [Key:Value]) -> [Key:Value] {
		var ret = self
		ret.addEntries(other)
		return ret
	}
}
