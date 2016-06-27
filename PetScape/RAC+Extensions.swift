//
//  RAC+Extensions.swift
//  PetScape
//
//  Created by David Warner on 6/24/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

extension NSObject {
	func rac_WillDeallocSignalProducer() -> SignalProducer<(), NoError> {
		return self.rac_willDeallocSignal()
			.toSignalProducer()
			.flatMapError { _ in SignalProducer<AnyObject?, NoError>.empty}
			.map {_ in ()}
	}
}