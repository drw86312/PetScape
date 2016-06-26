//
//  UIColor.swift
//  PetScape
//
//  Created by David Warner on 6/21/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import UIKit

enum PetScapeColor: UInt32 {
	
	case MainColor = 0x73c82c
	case LightGray = 0xf5f5f5
	
	var UIColor: UIKit.UIColor {
		return .init(color: self)
	}
}

extension UIColor {
	
	convenience init(color: PetScapeColor, alpha: CGFloat = 1.0) {
		self.init(red: CGFloat((color.rawValue >> 16) & 0xff) / 255,
		          green: CGFloat((color.rawValue >> 08) & 0xff) / 255,
		          blue: CGFloat((color.rawValue >> 00) & 0xff) / 255,
		          alpha: alpha)
	}
	
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
