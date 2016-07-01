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
	let filterProperty: MutableProperty<FilterStruct>
	
	init() {
		
		var animal: Animal? = nil
		var breed: String? = nil
		var size: Size? = nil
		var sex: Sex? = nil
		var age: Age? = nil
		var hasPhotos: Bool? = nil
		
		// Fetch stored filters
		if let decoded  = NSUserDefaults.standardUserDefaults().objectForKey(StreamViewModel.kFiltersKey) as? NSData,
			let filter = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? FilterClass {
			if let v = filter.animal, let enumValue = Animal(rawValue: v) { animal = enumValue }
			if let v = filter.size, let enumValue = Size(rawValue: v) { size = enumValue }
			if let v = filter.sex, let enumValue = Sex(rawValue: v) { sex = enumValue }
			if let v = filter.age, let enumValue = Age(rawValue: v) { age = enumValue }
			if let v = filter.breed { breed = v }
			if let v = filter.hasPhotos { hasPhotos = v }
		}
		
		// Assign filters to filters property
		filterProperty = MutableProperty<FilterStruct>(
			FilterStruct(animal: animal,
				breed: breed,
				size: size,
				sex: sex,
				age: age,
				hasPhotos: hasPhotos))
		
		locationStatus = AnyProperty((UIApplication.sharedApplication().delegate as! AppDelegate).locationManager.locationStatusProperty)
		
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
		
		let filterSignal = uniqueLocations
			.combineLatestWith(filterProperty.producer)
			.map { (location, filter) -> Endpoint<[Pet]> in
				return self.generateEndpoint(location,
					animal: filter.animal,
					breed: filter.breed,
					size: filter.size,
					sex: filter.sex,
					age: filter.age,
					offset: 0,
					count: self.count)
		}
				
		// Use this signal to cancel in-flight requests
		let disposalSignal = filterSignal
			.map { _ in () }
			.flatMapError { _ in SignalProducer<(), NoError>.empty }
		
		filterSignal.startWithNext { [unowned self] endpoint in
			self.load
				.apply(endpoint)
				.takeUntil(disposalSignal.skip(1).take(1))
				.on(disposed: { print("Disposing") })
				.start()
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
				} else if case .Failed = signal  {
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
			                                animal: filterProperty.value.animal,
			                                breed: filterProperty.value.breed,
			                                size: filterProperty.value.size,
			                                sex: filterProperty.value.sex,
			                                age: filterProperty.value.age,
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
