//
//  TextfieldCell.swift
//  PetScape
//
//  Created by David Warner on 7/11/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import UIKit

class TextfieldCell: UICollectionViewCell {
	
	let textField = UITextField()
	let divider = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.backgroundColor = UIColor(color: .LightGray)
		
		textField.textAlignment = .Center
		textField.tintColor = UIColor(color: .MainColor)
		textField.textColor = UIColor(color: .MainColor)
		textField.font = UIFont.systemFontOfSize(16)
		textField.keyboardAppearance = .Light
		textField.attributedPlaceholder = NSAttributedString(string: "Zip or City & State",
		                                                     attributes: [NSFontAttributeName : UIFont.systemFontOfSize(21),
																NSForegroundColorAttributeName : UIColor(color: .MainColor)])
		addSubview(textField)
		addSubview(divider)
		
		addConstraints()
	}
	
	private func addConstraints() {
		textField.autoPinEdge(.Left, toEdge: .Left, ofView: contentView, withOffset: 10)
		textField.autoPinEdge(.Right, toEdge: .Right, ofView: contentView, withOffset: -10)
		textField.autoPinEdge(.Top, toEdge: .Top, ofView: contentView)
		textField.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
		
		divider.autoPinEdge(.Left, toEdge: .Left, ofView: textField)
		divider.autoPinEdge(.Right, toEdge: .Right, ofView: textField)
		divider.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
		divider.autoSetDimension(.Height, toSize: 0.5)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
