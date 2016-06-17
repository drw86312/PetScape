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
	
	enum loadState {
		case Loading
		case Loaded
		case LoadingNext
	}
	
	var content: [Pet] = []
	var offset: Int = 0
	var loadNext: Action<(), [Pet], Error>?
	
	var animal : MutableProperty<Animal>?
	
	init() {
		self.loadNext = Action<(), [Pet], Error> { endpoint in
			return SignalProducer<[Pet], Error> { [unowned self] observer, _ in
				API.fetch(self.generateEndpoint("60606", offset: self.offset)) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self.content += content
						self.offset = self.content.count
						observer.sendNext(self.content)
						observer.sendCompleted()
					case .Failure(let error):
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

