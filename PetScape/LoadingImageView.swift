//
//  LoadingImageView.swift
//  PetScape
//
//  Created by David Warner on 6/26/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import UIKit

class LoadingImageView: UIImageView {
	
	let loadingView = CircularProgressView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(loadingView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		loadingView.center = CGPoint(x: bounds.origin.x + bounds.size.width/2, y: bounds.origin.y + bounds.size.height/2)
	}
}
