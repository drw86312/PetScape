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
	
	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

	private let buttonsStackView = UIStackView()
	let contactButton = UIButton()
	let favoriteButton = UIButton()
	let shareButton = UIButton()
	
	let titleLabel = UILabel()
	let detailLabel = UILabel()
	let rightLabel = UILabel()
	
	init() {
		super.init(frame: CGRectZero)
		
		backgroundColor = .clearColor()
		addSubview(blurView)
		
		rightLabel.font = UIFont.systemFontOfSize(12)
		rightLabel.numberOfLines = 0
		rightLabel.textColor = .whiteColor()
		rightLabel.textAlignment = .Right
		
		titleLabel.textColor = .whiteColor()
		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .ByTruncatingTail
		
		detailLabel.font = UIFont.systemFontOfSize(16)
		detailLabel.textColor = .whiteColor()
		detailLabel.numberOfLines = 2

		favoriteButton.setBackgroundImage(UIImage(named: "star")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		favoriteButton.setBackgroundImage(UIImage(named: "star_filled")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
		favoriteButton.tintColor = .whiteColor()
		
		shareButton.setBackgroundImage(UIImage(named: "share")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		shareButton.tintColor = .whiteColor()
		
		contactButton.setBackgroundImage(UIImage(named: "map")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
		contactButton.tintColor = .whiteColor()

		buttonsStackView.axis = .Horizontal
		buttonsStackView.distribution = .EqualSpacing
		buttonsStackView.alignment = .Fill
		buttonsStackView.spacing = 20;
		buttonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
		buttonsStackView.layoutMarginsRelativeArrangement = true

		buttonsStackView.addArrangedSubview(contactButton)
		buttonsStackView.addArrangedSubview(shareButton)
		buttonsStackView.addArrangedSubview(favoriteButton)
		
		addSubview(titleLabel)
		addSubview(detailLabel)
		addSubview(buttonsStackView)
		addSubview(rightLabel)

		addConstraints()
	}
	
	private func addConstraints() {
		blurView.autoPinEdgesToSuperviewEdges()
		
		titleLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: rightLabel)
		titleLabel.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 10)
		titleLabel.autoPinEdge(.Right, toEdge: .Left, ofView: rightLabel, withOffset: -10, relation: .LessThanOrEqual)
		
		detailLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
		detailLabel.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self, withOffset: -5)
		detailLabel.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 10)
		detailLabel.autoPinEdge(.Right, toEdge: .Left, ofView: buttonsStackView, withOffset: -10, relation: .LessThanOrEqual)
		
		rightLabel.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -10)
		rightLabel.autoPinEdge(.Top, toEdge: .Top, ofView: self, withOffset: 5)
		rightLabel.autoSetDimension(.Width, toSize: 65)
		
		buttonsStackView.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -10)
		buttonsStackView.autoPinEdge(.Top, toEdge: .Bottom, ofView: rightLabel, withOffset: 10)
		buttonsStackView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
		
		buttonsStackView.arrangedSubviews.forEach {
			$0.autoSetDimension(.Width, toSize: 30)
			$0.autoSetDimension(.Height, toSize: 30)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
