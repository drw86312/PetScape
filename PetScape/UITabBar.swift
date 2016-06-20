//
//  UITabBar.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {
	
	var darkStyle: Bool {
		set {
			barStyle = .Black
			tintColor = .whiteColor()
		}
		get {
			return barStyle == .Black
		}
	}
}