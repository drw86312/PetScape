//
//  FilterLocationCell.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import PureLayout

class FilterLocationCell: SimpleFilterCell {
	
	let textField = UITextField()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		textField.textAlignment = .Right
		textField.tintColor = .whiteColor()
		textField.textColor = .whiteColor()
		textField.font = UIFont.systemFontOfSize(16)
		textField.keyboardAppearance = .Dark
		textField.attributedPlaceholder = NSAttributedString(string: "Zip or City & State",
		                                                     attributes: [NSFontAttributeName : UIFont.systemFontOfSize(21),
																		  NSForegroundColorAttributeName : UIColor.whiteColor()])
		addSubview(textField)
		addConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addConstraints() {
		textField.autoPinEdge(.Left, toEdge: .Right, ofView: label, withOffset: 10)
		textField.autoPinEdge(.Right, toEdge: .Right, ofView: contentView, withOffset: -15)
		textField.autoPinEdge(.Top, toEdge: .Top, ofView: contentView)
		textField.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
	}
}
