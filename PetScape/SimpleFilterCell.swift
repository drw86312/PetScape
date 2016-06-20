//
//  SimpleFilterCell.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import PureLayout

class SimpleFilterCell: UITableViewCell {
	
	let label = UILabel()
	let divider = UIView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.backgroundColor = .blackColor()
		
		let selectedView = UIView()
		selectedView.backgroundColor = UIColor(white: 0.1, alpha: 1)
		selectedBackgroundView = selectedView
		
		label.sizeToFit()
		label.textColor = .whiteColor()
		label.font = UIFont.boldSystemFontOfSize(21)
		addSubview(label)
		
		divider.backgroundColor = .grayColor()
		addSubview(divider)
		
		addConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addConstraints() {
		label.autoPinEdge(.Left, toEdge: .Left, ofView: contentView, withOffset: 15)
		label.autoAlignAxisToSuperviewAxis(.Horizontal)
		
		divider.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
		divider.autoPinEdge(.Left, toEdge: .Left, ofView: contentView, withOffset: 15)
		divider.autoPinEdge(.Right, toEdge: .Right, ofView: contentView, withOffset: -15)
		divider.autoSetDimension(.Height, toSize: 1)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
