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
	
	private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
	let titleLabel = UILabel()
	let detailLabel = UILabel()
	let detailLabel2 = UILabel()
	let pageControl = UIPageControl()
	
	init() {
		super.init(frame: CGRectZero)
		
		titleLabel.textColor = .whiteColor()
		
		detailLabel.font = UIFont.systemFontOfSize(16)
		detailLabel.textColor = .whiteColor()
		
		detailLabel2.font = UIFont.systemFontOfSize(12)
		detailLabel2.textColor = .whiteColor()
		
		addSubview(blurView)
		addSubview(titleLabel)
		addSubview(detailLabel)
		addSubview(detailLabel2)
		addSubview(pageControl)
		
		addConstraints()
	}
	
	private func addConstraints() {
		blurView.autoPinEdgesToSuperviewEdges()
		
		pageControl.autoAlignAxisToSuperviewAxis(.Vertical)
		pageControl.autoPinEdgeToSuperviewEdge(.Top)
		pageControl.autoSetDimension(.Height, toSize: 25)
		
		titleLabel.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 15)
		titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: pageControl, withOffset: -5)
		
		detailLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
		detailLabel.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 15)
		
		detailLabel2.autoPinEdge(.Top, toEdge: .Bottom, ofView: detailLabel, withOffset: 5)
		detailLabel2.autoPinEdge(.Left, toEdge: .Left, ofView: self, withOffset: 15)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
