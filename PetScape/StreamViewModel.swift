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
		case notLoaded
		case loading
		case loadingNext
		case loaded
		case loadedNoResults
		case loadedLast
		case loadFailed
	}
	
	var content: [Pet] = []
	var offset: Int = 0
	
	var loadNext: Action<String, CountableRange<Int>, Error>?
	var reload: Action<String, CountableRange<Int>, Error>?
	
	private let _loadState = MutableProperty<LoadState>(.notLoaded)
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
		
		let appDelegate = UIApplication.shared().delegate as! AppDelegate
		locationStatus = AnyProperty(appDelegate.locationManager.locationStatusProperty)
		
		locationStatus
			.producer
			.start() { [unowned self] event in
				if case .next(let state) = event {
					switch state {
					case .notDetermined:
						print("Not Determined")
					case .denied:
						print("Denied")
					case .error(let error):
						print("Error: \(error)")
					case .some(let location):
//						print("Update Location: \(location)")
						self.reload?.apply(location).start()
					}
				}
		}
		
		self.reload = Action<String, CountableRange<Int>, Error> { location in
			self.offset = 0
			self._loadState.value = .loading
			return SignalProducer<CountableRange<Int>, Error> { [unowned self] observer, _ in
				API.fetch(self.endpoint(location)) { [unowned self] response in
					switch response.result {
					case .success(let content):
						if content.count == 0 {
							self._loadState.value = .loadedNoResults
						} else if content.count < self.count {
							self._loadState.value = .loadedLast
						} else {
							self._loadState.value = .loaded
						}
						self.content = content
						self.offset = self.content.count
						observer.sendNext(0..<self.content.count)
						observer.sendCompleted()
					case .failure(let error):
						self._loadState.value = .loadFailed
						observer.sendFailed(error)
					}
				}
			}
		}
		
		self.loadNext = Action<String, CountableRange<Int>, Error> { location in
			self._loadState.value = .loadingNext
			return SignalProducer<CountableRange<Int>, Error> { [unowned self] observer, _ in
				API.fetch(self.endpoint(location)) { [unowned self] response in
					switch response.result {
					case .success(let content):
						self._loadState.value = content.count < self.count ?.loadedLast : .loaded
						self.content += content
						self.offset = self.content.count
						observer.sendNext(self.content.count - content.count..<self.content.count)
						observer.sendCompleted()
					case .failure(let error):
						self._loadState.value = .loadFailed
						print(error)
						observer.sendFailed(error)
					}
				}
			}
		}
	}
	
	func endpoint(_ location: String) -> Endpoint<[Pet]> {
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

