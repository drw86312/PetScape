//
//  UITableView.swift
//  PetScape
//
//  Created by David Warner on 6/19/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit

extension UITableView {
	func reloadData(_ completion: ()->()) {
		UIView.animate(withDuration: 0, animations: { self.reloadData() })
		{ _ in completion() }
	}
}
