//
//  TableViewBackground.swift
//  PetScape
//
//  Created by David Warner on 6/17/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import UIKit

class TableViewBackground: UIView {
	
	let label = UILabel()
	let refreshButton = UIButton()
	
	init() {
		super.init(frame: CGRect.zero)
				
		label.text = "Refresh Failed"
		label.textColor = .white()
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 21)
		label.numberOfLines = 0
		
		refreshButton.setTitle("Retry", for: UIControlState())
		refreshButton.setTitleColor(.white(), for: UIControlState())
		refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 21)
		refreshButton.layer.masksToBounds = true
		refreshButton.layer.cornerRadius = 2.5
		refreshButton.layer.borderWidth = 2.0
		refreshButton.layer.borderColor = UIColor.white().cgColor
		
		addSubview(label)
		addSubview(refreshButton)
		
		addConstraints()
	}
	
	private func addConstraints() {
		label.autoAlignAxis(toSuperviewAxis: .vertical)
		label.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: -25)
		label.autoSetDimension(.width, toSize: 250)
		
		refreshButton.autoPinEdge(.top, to: .bottom, of: label, withOffset: 15)
		refreshButton.autoAlignAxis(toSuperviewAxis: .vertical)
		refreshButton.autoSetDimension(.width, toSize: 150)
		refreshButton.autoSetDimension(.height, toSize: 50)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
