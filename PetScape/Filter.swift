//
//  Filter.swift
//  PetScape
//
//  Created by David Warner on 6/23/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation

struct FilterStruct {
	
	let animal: Animal?
	let breed: String?
	let size: Size?
	let sex: Sex?
	let age: Age?
	let hasPhotos: Bool?
}

class FilterClass : NSObject, NSCoding {
	
	var animal: String?
	var breed: String?
	var size: String?
	var sex: String?
	var age: String?
	var hasPhotos: Bool?
	
	init(animal: String? = nil,
	     breed: String? = nil,
	     size: String? = nil,
	     sex: String? = nil,
	     age: String? = nil,
	     hasPhotos: Bool? = nil) {
		self.animal = animal
		self.breed = breed
		self.size = size
		self.sex = sex
		self.age = age
		self.hasPhotos = hasPhotos
	}
	
	required convenience init(coder aDecoder: NSCoder) {
		let animal = aDecoder.decodeObjectForKey("animal") as? String
		let breed = aDecoder.decodeObjectForKey("breed") as? String
		let size = aDecoder.decodeObjectForKey("size") as? String
		let sex = aDecoder.decodeObjectForKey("sex") as? String
		let age = aDecoder.decodeObjectForKey("age") as? String
		let hasPhotos = aDecoder.decodeObjectForKey("hasPhotos") as? Bool
		self.init(animal: animal, breed: breed, size: size, sex: sex, age: age, hasPhotos: hasPhotos)
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		if let animal = self.animal { aCoder.encodeObject(animal, forKey: "animal") }
		if let breed = self.breed { aCoder.encodeObject(breed, forKey: "breed") }
		if let size = self.size { aCoder.encodeObject(size, forKey: "size") }
		if let sex = self.sex { aCoder.encodeObject(sex, forKey: "sex") }
		if let age = self.age { aCoder.encodeObject(age, forKey: "age") }
		if let hasPhotos = self.hasPhotos { aCoder.encodeObject(hasPhotos, forKey: "hasPhotos") }
	}
}
