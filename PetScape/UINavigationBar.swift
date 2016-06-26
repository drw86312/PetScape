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
	
	var defaultStyle: Bool {
		set {
			barTintColor = UIColor(color: .MainColor)
			titleTextAttributes = [NSForegroundColorAttributeName: UIColor(color: .LightGray)]
		}
		get {
			return true
		}
	}
}