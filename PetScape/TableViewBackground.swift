//
//  TableViewBackground.swift
//  PetScape
//
//  Created by David Warner on 6/17/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import UIKit

class TableViewBackground: UIView {
	
	let label = UILabel()
	let refreshButton = UIButton()
	
	init() {
		super.init(frame: CGRectZero)
				
		label.textColor = UIColor(color: .MainColor)
		label.textAlignment = .Center
		label.font = UIFont.systemFontOfSize(21)
		label.numberOfLines = 0
		
		refreshButton.setTitle("Retry", forState: .Normal)
		refreshButton.setTitleColor(UIColor(color: .MainColor), forState: .Normal)
		refreshButton.titleLabel?.font = UIFont.boldSystemFontOfSize(26)
		refreshButton.layer.borderColor = UIColor(color: .MainColor).CGColor
		
		addSubview(label)
		addSubview(refreshButton)
		
		addConstraints()
	}
	
	private func addConstraints() {
		label.autoAlignAxisToSuperviewAxis(.Vertical)
		label.autoAlignAxis(.Horizontal, toSameAxisOfView: self, withOffset: -25)
		label.autoSetDimension(.Width, toSize: 250)
		
		refreshButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: label, withOffset: 15)
		refreshButton.autoAlignAxisToSuperviewAxis(.Vertical)
		refreshButton.autoSetDimension(.Width, toSize: 150)
		refreshButton.autoSetDimension(.Height, toSize: 50)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
