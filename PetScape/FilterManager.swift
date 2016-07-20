//
//  FilterManager.swift
//  PetScape
//
//  Created by David Warner on 7/5/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct Filter {
	let animal: Animal?
	let breed: String?
	let size: Size?
	let sex: Sex?
	let age: Age?
	let hasPhotos: Bool?
}

extension Filter: Equatable {}

func == (lhs: Filter, rhs: Filter) -> Bool {
	let isEqual =
		lhs.animal == rhs.animal &&
			lhs.breed == rhs.breed &&
			lhs.size == rhs.size &&
			lhs.sex == rhs.sex &&
			lhs.age == rhs.age &&
			lhs.hasPhotos == rhs.hasPhotos
	return isEqual
}

class FilterManager {
	
	let filter: MutableProperty<Filter>
	static let kFiltersKey = "filters"
	
	init() {
		filter = MutableProperty<Filter>(FilterManager.fetchStoredFilter())
	}
	
	static func fetchStoredFilter() -> Filter {
		
		var animal: Animal? = nil
		var breed: String? = nil
		var size: Size? = nil
		var sex: Sex? = nil
		var age: Age? = nil
		var hasPhotos: Bool? = nil
		
		// Fetch stored filters
		if let decoded  = NSUserDefaults.standardUserDefaults().objectForKey(FilterManager.kFiltersKey) as? NSData,
			let filter = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? FilterClass {
			if let v = filter.animal, let enumValue = Animal(rawValue: v) { animal = enumValue }
			if let v = filter.size, let enumValue = Size(rawValue: v) { size = enumValue }
			if let v = filter.sex, let enumValue = Sex(rawValue: v) { sex = enumValue }
			if let v = filter.age, let enumValue = Age(rawValue: v) { age = enumValue }
			if let v = filter.breed { breed = v }
			if let v = filter.hasPhotos { hasPhotos = v }
		}
		
		return Filter(animal: animal,
		              breed: breed,
		              size: size,
		              sex: sex,
		              age: age,
		              hasPhotos: hasPhotos)
	}
	
	static func saveFilter(filter: Filter) {
		let filterClass = FilterClass(animal: filter.animal?.rawValue,
		                              breed: filter.breed,
		                              size: filter.size?.rawValue,
		                              sex: filter.sex?.rawValue,
		                              age: filter.age?.rawValue,
		                              hasPhotos: filter.hasPhotos)
		NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(filterClass),
		                                                forKey: FilterManager.kFiltersKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
}

// Class should only be used internally for saving and retrieving stored filters
final class FilterClass : NSObject, NSCoding {
	
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
