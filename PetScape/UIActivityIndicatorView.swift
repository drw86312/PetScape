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
	
	func loading(signal: Signal<Bool, NoError>) {
		signal
			.observeOn(UIScheduler())
			.observeNext { [unowned self] loading in
				loading ? self.startAnimating() : self.stopAnimating()
		}
	}
}


