//
//  UIColor.swift
//  PetScape
//
//  Created by David Warner on 6/21/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	func imageFromColor() -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetFillColorWithColor(context, self.CGColor)
		CGContextFillRect(context, rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}
