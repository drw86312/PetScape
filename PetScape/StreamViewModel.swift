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
		case LoadedLast
		case LoadFailed
	}
	
	var content: [Pet] = []
	var offset: Int = 0
	
	var loadNext: Action<String, [Pet], Error>?
	var reload: Action<String, [Pet], Error>?
	
	private let _loadState = MutableProperty<LoadState>(.NotLoaded)
	let loadState: AnyProperty<LoadState>
	
	var location = ""
	var count = 10
	var animal : Animal?
	var breed : String?
	var size : Size?
	var sex : Sex?
	var age : Age?
	
	init() {
		self.loadState = AnyProperty(_loadState)
		
		self.reload = Action<String, [Pet], Error> { location in
			self.location = location
			print("Location: \(location)")
			self.offset = 0
			self._loadState.value = .Loading
			return SignalProducer<[Pet], Error> { [unowned self] observer, _ in
				API.fetch(self.endpoint()) { [unowned self] response in
					print(self.endpoint())
					switch response.result {
					case .Success(let content):
						self._loadState.value = content.count < self.count ?.LoadedLast : .Loaded
						self.content = content
						self.offset = self.content.count
						observer.sendNext(self.content)
						observer.sendCompleted()
					case .Failure(let error):
						self._loadState.value = .LoadFailed
						observer.sendFailed(error)
					}
				}
			}
		}
		
		self.loadNext = Action<String, [Pet], Error> { location in
			self.location = location
			self._loadState.value = .LoadingNext
			return SignalProducer<[Pet], Error> { [unowned self] observer, _ in
				API.fetch(self.endpoint()) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self._loadState.value = content.count < self.count ?.LoadedLast : .Loaded
						self.content += content
						self.offset = self.content.count
						observer.sendNext(self.content)
						observer.sendCompleted()
					case .Failure(let error):
						self._loadState.value = .LoadFailed
						observer.sendFailed(error)
					}
				}
			}
		}
	}
	
	func endpoint() -> Endpoint<[Pet]> {
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

