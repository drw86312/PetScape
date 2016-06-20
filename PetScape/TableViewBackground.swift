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
				
		label.text = "Refresh Failed"
		label.textColor = .whiteColor()
		label.font = UIFont.systemFontOfSize(21)
		
		refreshButton.setTitle("Retry", forState: .Normal)
		refreshButton.setTitleColor(.whiteColor(), forState: .Normal)
		refreshButton.titleLabel?.font = UIFont.systemFontOfSize(21)
		refreshButton.layer.masksToBounds = true
		refreshButton.layer.cornerRadius = 2.5
		refreshButton.layer.borderWidth = 2.0
		refreshButton.layer.borderColor = UIColor.whiteColor().CGColor
		
		addSubview(label)
		addSubview(refreshButton)
		
		addConstraints()
	}
	
	private func addConstraints() {
		label.autoAlignAxisToSuperviewAxis(.Vertical)
		label.autoAlignAxis(.Horizontal, toSameAxisOfView: self, withOffset: -25)
		
		refreshButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: label, withOffset: 10)
		refreshButton.autoAlignAxisToSuperviewAxis(.Vertical)
		refreshButton.autoSetDimension(.Width, toSize: 150)
		refreshButton.autoSetDimension(.Height, toSize: 50)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
