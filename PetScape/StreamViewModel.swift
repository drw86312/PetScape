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
		case Loaded
		case LoadedLast
		case LoadingNext
		case LoadFailed
	}
	
	var content: [Pet] = []
	var offset: Int = 0
	
	var loadNext: Action<(), [Pet], Error>?
	var reload: Action<(), [Pet], Error>?
	
	let _loadState = MutableProperty<LoadState>(.NotLoaded)
	let loadState: AnyProperty<LoadState>
	
	var animal : MutableProperty<Animal>?
	
	init() {
		self.loadState = AnyProperty(_loadState)
		
		self.reload = Action<(), [Pet], Error> { endpoint in
			print("Reload")
			self.offset = 0
			self._loadState.value = .Loading
			return SignalProducer<[Pet], Error> { [unowned self] observer, _ in
				API.fetch(self.generateEndpoint("60606", offset: self.offset)) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self._loadState.value = content.count > 0 ? .Loaded : .LoadedLast
						self.content = content
						self.offset = self.content.count
						print("Send Next: \(observer)")
						observer.sendNext(self.content)
						observer.sendCompleted()
					case .Failure(let error):
						self._loadState.value = .LoadFailed
						observer.sendFailed(error)
					}
				}
			}
		}
		
		self.loadNext = Action<(), [Pet], Error> { endpoint in
			self._loadState.value = .LoadingNext
			return SignalProducer<[Pet], Error> { [unowned self] observer, _ in
				API.fetch(self.generateEndpoint("60606", offset: self.offset)) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self._loadState.value = content.count > 0 ? .Loaded : .LoadedLast
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
	
	func generateEndpoint(location: String, offset: Int) -> Endpoint<[Pet]> {
		return Endpoint<Pet>.findPets(location, offset: offset)
	}
}

