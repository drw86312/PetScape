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
		
		textField.textAlignment = .right
		textField.tintColor = .white()
		textField.textColor = .white()
		textField.font = UIFont.systemFont(ofSize: 16)
		textField.keyboardAppearance = .dark
		textField.attributedPlaceholder = AttributedString(string: "Zip or City & State",
		                                                     attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 21),
																		  NSForegroundColorAttributeName : UIColor.white()])
		addSubview(textField)
		addConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addConstraints() {
		textField.autoPinEdge(.left, to: .right, of: label, withOffset: 10)
		textField.autoPinEdge(.right, to: .right, of: contentView, withOffset: -15)
		textField.autoPinEdge(.top, to: .top, of: contentView)
		textField.autoPinEdge(.bottom, to: .bottom, of: contentView)
	}
}
