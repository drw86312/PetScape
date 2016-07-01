//
//  PetCellLabelView.swift
//  PetScape
//
//  Created by David Warner on 6/14/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import PureLayout

class PetCellLabelView: UIView {
	
	private let rightStackView = UIStackView()
	let contactButton = UIButton()
	let favoriteButton = UIButton()
	let shareButton = UIButton()
	
	private let topStackView = UIStackView()
	let titleLabel = UILabel()
	let detailLabel = UILabel()
	
	let detailLabel2 = UILabel()
	
	init() {
		super.init(frame: CGRectZero)
		backgroundColor = UIColor(color: .MainColor)
		
		detailLabel.font = UIFont.systemFontOfSize(16)
		detailLabel2.font = UIFont.systemFontOfSize(12)
		
		[titleLabel, detailLabel, detailLabel2].forEach {
			$0.textColor = .whiteColor()
			$0.numberOfLines = 1
			$0.lineBreakMode = .ByTruncatingTail
		}
		
		favoriteButton.setBackgroundImage(UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		favoriteButton.setBackgroundImage(UIImage(named: "star_filled")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
		favoriteButton.tintColor = .whiteColor()
		
		shareButton.setBackgroundImage(UIImage(named: "share")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		shareButton.tintColor = .whiteColor()
		
		contactButton.setBackgroundImage(UIImage(named: "map")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		contactButton.tintColor = .whiteColor()
		
		rightStackView.axis = .Horizontal
		rightStackView.distribution = .EqualSpacing
		rightStackView.alignment = .Fill
		rightStackView.spacing = 10;
		rightStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
		rightStackView.layoutMarginsRelativeArrangement = true
		
		rightStackView.addArrangedSubview(contactButton)
		rightStackView.addArrangedSubview(shareButton)
		rightStackView.addArrangedSubview(favoriteButton)
		
		topStackView.axis = .Vertical
		topStackView.distribution = .FillEqually
		topStackView.alignment = .Leading
		topStackView.spacing = 0
		
		topStackView.addArrangedSubview(titleLabel)
		topStackView.addArrangedSubview(detailLabel)
		
		addSubview(topStackView)
		addSubview(rightStackView)
		addSubview(detailLabel2)

		addConstraints()
	}
	
	private func addConstraints() {
		
		rightStackView.arrangedSubviews.forEach {
			$0.autoSetDimension(.Width, toSize: 30)
			$0.autoSetDimension(.Height, toSize: 30)
		}
		
		rightStackView.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -10)
		rightStackView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
		
		topStackView.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 10)
		topStackView.autoPinEdge(.Top, toEdge: .Top, ofView: self, withOffset: 5)
		topStackView.autoPinEdge(.Bottom, toEdge: .Top, ofView: rightStackView, withOffset: -5)
		topStackView.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -10)
		
		detailLabel2.autoPinEdge(.Left, toEdge: .Left, ofView: topStackView)
		detailLabel2.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self, withOffset: -5)
		detailLabel2.autoPinEdge(.Right, toEdge: .Left, ofView: rightStackView, withOffset: -15)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
