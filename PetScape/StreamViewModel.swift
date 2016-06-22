//
//  StreamViewModel.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa

class StreamViewModel {
	
	enum LoadState {
		case NotLoaded
		case Loading
		case LoadingNext
		case Loaded
		case LoadedNoResults
		case LoadedLast
		case LoadFailed
	}
	
	var content: [Pet] = []
	var offset: Int = 0
	
	var loadNext: Action<String, Range<Int>, Error>?
	var reload: Action<String, Range<Int>, Error>?
	
	private let _loadState = MutableProperty<LoadState>(.NotLoaded)
	let loadState: AnyProperty<LoadState>
	
	let locationStatus: AnyProperty<LocationManager.LocationStatus>
	
	var count = 10
	var animal : Animal?
	var breed : String?
	var size : Size?
	var sex : Sex?
	var age : Age?
	
	init() {
		self.loadState = AnyProperty(_loadState)
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		locationStatus = AnyProperty(appDelegate.locationManager.locationStatusProperty)
		
		locationStatus
			.producer
			.start() { [unowned self] event in
				if case .Next(let state) = event {
					switch state {
					case .NotDetermined:
						print("Not Determined")
					case .Denied:
						print("Denied")
					case .Error(let error):
						print("Error: \(error)")
					case .Some(let location):
//						print("Update Location: \(location)")
						self.reload?.apply(location).start()
					}
				}
		}
		
		self.reload = Action<String, Range<Int>, Error> { location in
			self.offset = 0
			self._loadState.value = .Loading
			return SignalProducer<Range<Int>, Error> { [unowned self] observer, _ in
				API.fetch(self.endpoint(location)) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						if content.count == 0 {
							self._loadState.value = .LoadedNoResults
						} else if content.count < self.count {
							self._loadState.value = .LoadedLast
						} else {
							self._loadState.value = .Loaded
						}
						self.content = content
						self.offset = self.content.count
						observer.sendNext(0..<self.content.count)
						observer.sendCompleted()
					case .Failure(let error):
						self._loadState.value = .LoadFailed
						observer.sendFailed(error)
					}
				}
			}
		}
		
		self.loadNext = Action<String, Range<Int>, Error> { location in
			self._loadState.value = .LoadingNext
			return SignalProducer<Range<Int>, Error> { [unowned self] observer, _ in
				API.fetch(self.endpoint(location)) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self._loadState.value = content.count < self.count ?.LoadedLast : .Loaded
						self.content += content
						self.offset = self.content.count
						observer.sendNext(self.content.count - content.count..<self.content.count)
						observer.sendCompleted()
					case .Failure(let error):
						self._loadState.value = .LoadFailed
						print(error)
						observer.sendFailed(error)
					}
				}
			}
		}
	}
	
	func endpoint(location: String) -> Endpoint<[Pet]> {
		return Endpoint<Pet>.findPets(location,
		                              animal: animal,
		                              breed: breed,
		                              size: size,
		                              sex: sex,
		                              age: age,
		                              offset: offset,
		                              count: count)
	}
}

