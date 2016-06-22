//
//  BaseModalViewController.swift
//  PetScape
//
//  Created by David Warner on 6/21/16.
//  Copyright © 2016 drw. All rights reserved.
//

import PureLayout
import UIKit

class BaseModalViewController: UIViewController {
	
	struct Constants {
		static let animationDuration: Double = 0.8
		static let springDamping: CGFloat = 0.6
		static let springVelocity: CGFloat = 0.7
	}
	
	let contentView = UIView()
	
	var contentViewHorizontalConstraint: NSLayoutConstraint!
	var contentViewHeightConstraint: NSLayoutConstraint!
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
		view.alpha = 0
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseModalViewController.dismiss)))
		
		contentView.backgroundColor = .white()
		contentView.layer.masksToBounds = true
		contentView.layer.cornerRadius = 2.5
		
		view.addSubview(contentView)
		
		addConstraints()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		contentViewHorizontalConstraint.constant = 0
		
		UIView.animate(
			withDuration: Constants.animationDuration,
			delay: 0,
			usingSpringWithDamping: Constants.springDamping,
			initialSpringVelocity: Constants.springVelocity,
			options: UIViewAnimationOptions(rawValue: 0),
			animations: {
				self.view.alpha = 1.0
				self.view.layoutIfNeeded()
			},
			completion: nil)
	}
	
	private func addConstraints() {
		contentView.autoSetDimension(.width, toSize: 250)
		contentView.autoAlignAxis(toSuperviewAxis: .vertical)
		contentViewHeightConstraint = contentView.autoSetDimension(.height, toSize: 300)
		contentViewHorizontalConstraint = contentView.autoAlignAxis(toSuperviewAxis: .horizontal)
		
		contentViewHorizontalConstraint.constant = UIScreen.main().bounds.height/2 + contentViewHeightConstraint.constant
	}
	
	func dismiss() {
		contentViewHorizontalConstraint.constant = UIScreen.main().bounds.height/2 + contentViewHeightConstraint.constant
		UIView.animate(
			withDuration: Constants.animationDuration,
			delay: 0,
			usingSpringWithDamping: Constants.springDamping,
			initialSpringVelocity: Constants.springVelocity,
			options: UIViewAnimationOptions(rawValue: 0),
			animations: {
				self.view.alpha = 0.0
				self.view.layoutIfNeeded()
			},
			completion: { finished in
				self.presentingViewController?.dismiss(animated: false, completion: nil)
		})
	}
}
