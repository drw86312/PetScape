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
	
	private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
	let titleLabel = UILabel()
	let detailLabel = UILabel()
	let detailLabel2 = UILabel()
	let pageControl = UIPageControl()
	
	init() {
		super.init(frame: CGRect.zero)
		
		titleLabel.textColor = .white()
		
		detailLabel.font = UIFont.systemFont(ofSize: 16)
		detailLabel.textColor = .white()
		
		detailLabel2.font = UIFont.systemFont(ofSize: 12)
		detailLabel2.textColor = .white()
		
		addSubview(blurView)
		addSubview(titleLabel)
		addSubview(detailLabel)
		addSubview(detailLabel2)
		addSubview(pageControl)
		
		addConstraints()
	}
	
	private func addConstraints() {
		blurView.autoPinEdgesToSuperviewEdges()
		
		pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
		pageControl.autoPinEdge(toSuperviewEdge: .top)
		pageControl.autoSetDimension(.height, toSize: 25)
		
		titleLabel.autoPinEdge(.left, to: .left, of: self, withOffset: 15)
		titleLabel.autoPinEdge(.top, to: .bottom, of: pageControl, withOffset: -5)
		
		detailLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 5)
		detailLabel.autoPinEdge(.left, to: .left, of: self, withOffset: 15)
		
		detailLabel2.autoPinEdge(.top, to: .bottom, of: detailLabel, withOffset: 5)
		detailLabel2.autoPinEdge(.left, to: .left, of: self, withOffset: 15)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
