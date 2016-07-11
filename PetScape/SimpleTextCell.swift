//
//  SimpleTextCell.swift
//  PetScape
//
//  Created by David Warner on 7/11/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import PureLayout

class SimpleTextCell: UICollectionViewCell {
	
	let leftLabel = UILabel()
	let rightLabel = UILabel()
	let accessoryImageView = UIImageView()
	let divider = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.backgroundColor = UIColor(color: .LightGray)
		
		leftLabel.textAlignment = .Left
		rightLabel.textAlignment = .Right
		
		leftLabel.font = UIFont.systemFontOfSize(21)
		divider.backgroundColor = .lightGrayColor()
		
		addSubview(leftLabel)
		addSubview(rightLabel)
		addSubview(accessoryImageView)
		addSubview(divider)

		addConstraints()
	}
	
	private func addConstraints() {
		leftLabel.autoPinEdge(.Left, toEdge: .Left, ofView: contentView, withOffset: 10)
		leftLabel.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
		leftLabel.autoPinEdge(.Top, toEdge: .Top, ofView: contentView)
		
		accessoryImageView.autoPinEdge(.Right, toEdge: .Right, ofView: contentView, withOffset: -10)
		accessoryImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: contentView)
		accessoryImageView.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
		
		rightLabel.autoPinEdge(.Right, toEdge: .Left, ofView: accessoryImageView, withOffset: -10)
		rightLabel.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
		rightLabel.autoPinEdge(.Top, toEdge: .Top, ofView: contentView)
		rightLabel.autoPinEdge(.Left, toEdge: .Right, ofView: leftLabel, withOffset: 10)
		
		divider.autoPinEdge(.Left, toEdge: .Left, ofView: leftLabel)
		divider.autoPinEdge(.Right, toEdge: .Right, ofView: accessoryImageView)
		divider.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
		divider.autoSetDimension(.Height, toSize: 0.5)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
