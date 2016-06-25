//
//  StreamViewModel.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

class StreamViewModel {
	
	static let kFiltersKey = "filters"
	
	enum LoadState {
		case NotLoaded
		case Loading
		case Loaded
		case LoadedNoResults
		case LoadedLast
		case LoadFailed
	}
	
	var content: [Pet] = []
	var count = 10
	
	var load: Action<Endpoint<[Pet]>, Range<Int>, Error>!
	
	private let _loadState = MutableProperty<LoadState>(.NotLoaded)
	let loadState: AnyProperty<LoadState>
	
	let locationStatus: AnyProperty<LocationManager.LocationStatus>
	
	let offset = MutableProperty<Int>(0)
	let animal: MutableProperty<Animal?>
	let breed: MutableProperty<String?>
	let size: MutableProperty<Size?>
	let sex: MutableProperty<Sex?>
	let age: MutableProperty<Age?>
	
	init() {
		
		var optionalAnimal: Animal? = nil
		var optionalBreed: String? = nil
		var optionalSize: Size? = nil
		var optionalSex: Sex? = nil
		var optionalAge: Age? = nil
		
		
		// Fetch saved filters, stored locally.
		if let decoded  = NSUserDefaults.standardUserDefaults().objectForKey(StreamViewModel.kFiltersKey) as? NSData,
			let filter = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? Filter {
			if let v = filter.animal, let enumValue = Animal(rawValue: v) { optionalAnimal = enumValue }
			if let v = filter.size, let enumValue = Size(rawValue: v) { optionalSize = enumValue }
			if let v = filter.sex, let enumValue = Sex(rawValue: v) { optionalSex = enumValue }
			if let v = filter.age, let enumValue = Age(rawValue: v) { optionalAge = enumValue }
			if let v = filter.breed { optionalBreed = v }
		}
		
		// Instantiate filter properties
		animal = MutableProperty<Animal?>(optionalAnimal)
		breed = MutableProperty<String?>(optionalBreed)
		size = MutableProperty<Size?>(optionalSize)
		sex = MutableProperty<Sex?>(optionalSex)
		age = MutableProperty<Age?>(optionalAge)
		
		self.loadState = AnyProperty(_loadState)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		locationStatus = AnyProperty(appDelegate.locationManager.locationStatusProperty)
		
		let uniqueLocations = locationStatus
			.producer
			.map { state -> String? in
				if case .Some(let location) = state {
					return location
				}
				return nil
			}
			.skipRepeats(==)
			.ignoreNil()
		
		let combined = uniqueLocations
			.combineLatestWith(animal.producer)
			.combineLatestWith(breed.producer)
			.combineLatestWith(size.producer)
			.combineLatestWith(sex.producer)
			.combineLatestWith(age.producer)
			.combineLatestWith(offset.producer)
			// Unpack the tuples
			.map { (tuple, offset) -> (String, Animal?, String?, Size?, Sex?, Age?, Int) in
				let age = tuple.1
				let sex = tuple.0.1
				let size = tuple.0.0.1
				let breed = tuple.0.0.0.1
				let animal = tuple.0.0.0.0.1
				let location = tuple.0.0.0.0.0
				return (location, animal, breed, size, sex, age, offset)
			}
			.map { [unowned self] tuple -> Endpoint<[Pet]> in
				return Endpoint<Pet>.findPets(
					tuple.0,
					animal: tuple.1,
					breed: tuple.2,
					size: tuple.3,
					sex: tuple.4,
					age: tuple.5,
					offset: tuple.6,
					count: self.count)
		}
		
		// Use this signal to cancel in-flight requests
		let disposalSignal = combined
			.map { _ in () }
			.flatMapError { _ in SignalProducer<(), NoError>.empty }
		
		combined.startWithNext { endpoint in
			self.load
				.apply(endpoint)
				.takeUntil(disposalSignal
					.skip(1)
					.take(1))
				.start()
		}
		
		self.load = Action<Endpoint<[Pet]>, Range<Int>, Error> { endpoint in
			self._loadState.value = .Loading
			return SignalProducer<Range<Int>, Error> { [unowned self] observer, _ in
				API.fetch(endpoint) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						if content.count == 0 {
							self._loadState.value = .LoadedNoResults
						} else if content.count < self.count {
							self._loadState.value = .LoadedLast
						} else {
							self._loadState.value = .Loaded
						}
						self.content += content
						observer.sendNext(self.content.count - content.count..<self.content.count)
						observer.sendCompleted()
					case .Failure(let error):
						self._loadState.value = .LoadFailed
						observer.sendFailed(error)
					}
				}
			}
		}
	}
}
