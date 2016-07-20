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
		
	enum LoadState {
		case NotLoaded
		case Loading
		case Loaded
		case NoResults
		case Failed
	}
	
	let locationManager: LocationManager
	let filterManager: FilterManager
	
	var content: [Pet] = []
	var count = 10
	var offset = 0
	
	var load: Action<Endpoint<[Pet]>, Range<Int>, Error>!
	let loadState = MutableProperty<LoadState>(.NotLoaded)
	
	var dataErased: (() -> ())?
	
	let locationStatus: AnyProperty<LocationManager.LocationStatus>
	
	init(locationManager: LocationManager, filterManager: FilterManager) {
		self.filterManager = filterManager
		self.locationManager = locationManager
		locationStatus = AnyProperty(locationManager.locationStatusProperty)
		
		let locations = locationStatus
			.producer
			.filter { state in
				if case .Some = state { return true }
				return false
			}
			.map { state -> String? in
				if case .Some(let location) = state { return location }
				return nil
			}
			.skipRepeats(==)
			.ignoreNil()
		
		let filter = filterManager
			.filter
			.producer
			.skipRepeats()
			.throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
		
		locations
			.combineLatestWith(filter)
			.startWithNext { [unowned self] _ in
				self.reload()
		}
		
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
	
	func reload() {
		content = []
		offset = 0
		dataErased?()
		loadNext()
	}

	func loadNext() {
		if case .Some(let location) = locationStatus.value {
			let endpoint = StreamViewModel.generateEndpoint(location,
			                                animal: filterManager.filter.value.animal,
			                                breed: filterManager.filter.value.breed,
			                                size: filterManager.filter.value.size,
			                                sex: filterManager.filter.value.sex,
			                                age: filterManager.filter.value.age,
			                                offset: self.offset,
			                                count: self.count)
			load
				.apply(endpoint)
				.start()
		}
	}
	
	static func generateEndpoint(location: String,
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
