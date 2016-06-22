//
//  UINavigationBar.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
	
	var darkStyle: Bool {
		set {
			barStyle = .blackTranslucent
			tintColor = .white()
		}
		get {
			return barStyle == .blackTranslucent
		}
	}
}
