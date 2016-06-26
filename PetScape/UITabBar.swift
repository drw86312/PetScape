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
	
	var defaultStyle: Bool {
		set {
			tintColor = UIColor(color: .MainColor)
		}
		get {
			return barStyle == .Black
		}
	}
}