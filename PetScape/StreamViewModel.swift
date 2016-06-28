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
		case NoResults
		case Failed
	}
	
	var content: [Pet] = []
	var count = 10
	var offset = 0
	
	var load: Action<Endpoint<[Pet]>, Range<Int>, Error>!
	let loadState = MutableProperty<LoadState>(.NotLoaded)
	
	let locationStatus: AnyProperty<LocationManager.LocationStatus>
	
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
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		locationStatus = AnyProperty(appDelegate.locationManager.locationStatusProperty)
		
		let uniqueLocations = locationStatus
			.producer
			.map { state -> String? in
				if case .Some(let location) = state {
					return "60642"
				}
				return nil
			}
			.skipRepeats(==)
			.ignoreNil()
		
		let filterSignal = uniqueLocations
			.combineLatestWith(animal.producer)
			.combineLatestWith(breed.producer)
			.combineLatestWith(size.producer)
			.combineLatestWith(sex.producer)
			.combineLatestWith(age.producer)
			// Unpack tuples
			.map { (tuple, age) -> (String, Animal?, String?, Size?, Sex?, Age?) in
				let sex = tuple.1
				let size = tuple.0.1
				let breed = tuple.0.0.1
				let animal = tuple.0.0.0.1
				let location = tuple.0.0.0.0
				return (location, animal, breed, size, sex, age)
			}
			.map { [unowned self] tuple -> Endpoint<[Pet]> in
				return self.generateEndpoint(tuple.0,
					animal: tuple.1,
					breed: tuple.2,
					size: tuple.3,
					sex: tuple.4,
					age: tuple.5,
					offset: 0,
					count: self.count)
			}
		
		// Use this signal to cancel in-flight requests
		let disposalSignal = filterSignal
			.map { _ in () }
			.flatMapError { _ in SignalProducer<(), NoError>.empty }
		
//		disposalSignal
//			.skip(1)
//			.take(1)
//			.startWithNext {
//				print("Disposal")
//		}
		
//		uniqueLocations.startWithNext { loc in
//			print(loc)
//		}
		
		filterSignal.startWithNext { [unowned self] endpoint in
			if !self.load.executing.value {
				self.load
					.apply(endpoint)
					.takeUntil(disposalSignal.skip(1).take(1))
					.on(disposed: { print("Disposing") })
					.start()
			}
		}
		
//		client.resourceList()
//			.flatMap(.Latest) { (ids) -> SignalProducer<Resource, MyError> in
//				let signalProducers = ids.map { client.fetchResource($0) }
//				return SignalProducer(values: signalProducers).flatten(.Merge)
//		}
		
//		let loading = SignalProducer<State, NoError>(value: .Loading)

		
		self.load = Action<Endpoint<[Pet]>, Range<Int>, Error> { endpoint in
			return SignalProducer<Range<Int>, Error> { [unowned self] observer, disposable in
				API.fetch(endpoint) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self.content += content
						self.offset = self.content.count
						observer.sendNext(self.content.count - content.count..<self.content.count)
						observer.sendCompleted()
					case .Failure(let error):
						observer.sendFailed(error)
					}
				}
			}
		}
		
		// Derive .Loading state by merging location scanning and fetching data signals
		let isFindingLocation = locationStatus
			.signal
			.map { status -> LoadState? in
				if case .Scanning = status { return .Loading }
				return nil
			}
			.ignoreNil()
		
		let isFetchingData = self.load
			.executing
			.signal
			.map { executing -> LoadState? in
				return executing ? .Loading : nil
			}
			.ignoreNil()
		
		let loading = Signal.merge([isFindingLocation, isFetchingData])
		
		// Derive .Loaded states from events on the load action
		let loaded = self.load
			.events
			.map { signal -> LoadState? in
				if case .Next(let range) = signal {
					if range.endIndex == 0 {
						return .NoResults
					}
					return .Loaded
				} else if case .Failed = signal {
					return .Failed
				} else if case .Interrupted = signal {
					return .Failed
				}
				return nil
			}
			.ignoreNil()
		
		// Merge loading and loaded signals
		self.loadState <~ Signal.merge([loaded, loading]).skipRepeats()
	}
	
	func loadNext() {
		if case .Some(let location) = locationStatus.value {
			let endpoint = generateEndpoint(location,
			                                animal: animal.value,
			                                breed: breed.value,
			                                size: size.value,
			                                sex: sex.value,
			                                age: age.value,
			                                offset: self.offset,
			                                count: self.count)
			load
				.apply(endpoint)
				.start()
		}
	}
	
	func reload() {
		if content.count != 0 { content = [] }
		self.offset = 0
		loadNext()
	}
	
	func generateEndpoint(location: String,
	                      animal: Animal?,
	                      breed: String?,
	                      size: Size?,
	                      sex: Sex?,
	                      age: Age?,
	                      offset: Int,
	                      count: Int) -> Endpoint<[Pet]> {
		return Endpoint<Pet>.findPets(
			location,
			animal: animal,
			breed: breed,
			size: size,
			sex: sex,
			age: age,
			offset: offset,
			count: count)
	}
}
