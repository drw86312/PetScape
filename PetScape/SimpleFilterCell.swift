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
		
		contentView.backgroundColor = .black()
		
		let selectedView = UIView()
		selectedView.backgroundColor = UIColor(white: 0.1, alpha: 1)
		selectedBackgroundView = selectedView
		
		label.sizeToFit()
		label.textColor = .white()
		label.font = UIFont.boldSystemFont(ofSize: 21)
		addSubview(label)
		
		divider.backgroundColor = .gray()
		addSubview(divider)
		
		addConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addConstraints() {
		label.autoPinEdge(.left, to: .left, of: contentView, withOffset: 15)
		label.autoAlignAxis(toSuperviewAxis: .horizontal)
		
		divider.autoPinEdge(.bottom, to: .bottom, of: contentView)
		divider.autoPinEdge(.left, to: .left, of: contentView, withOffset: 15)
		divider.autoPinEdge(.right, to: .right, of: contentView, withOffset: -15)
		divider.autoSetDimension(.height, toSize: 1)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}
