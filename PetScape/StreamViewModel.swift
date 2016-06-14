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
	
	var content: [Pet] = []
	var loadNext: Action<Endpoint<[Pet]>, [Pet], Error>?
	
	init() {
		self.loadNext = Action<Endpoint<[Pet]>, [Pet], Error> { endpoint in
			return SignalProducer<[Pet], Error> { observer, _ in
				API.fetch(endpoint) { [unowned self] response in
					switch response.result {
					case .Success(let content):
						self.content += content
						observer.sendNext(content)
						observer.sendCompleted()
					case .Failure(let error):
						observer.sendFailed(error)
					}
				}
			}
		}
	}
}

