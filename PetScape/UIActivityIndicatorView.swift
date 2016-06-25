//
//  UIActivityIndicatorView.swift
//  PetScape
//
//  Created by David Warner on 6/24/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import UIKit

extension UIActivityIndicatorView {
	
	func loading(signal: SignalProducer<Bool, NoError>) {
		signal
			.producer
			.takeUntil(rac_WillDeallocSignalProducer())
			.start() { event in
				if case .Next(let loading) = event {
					loading ? self.startAnimating() : self.stopAnimating()
				}
		}
	}
}


