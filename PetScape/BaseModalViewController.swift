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
		static let animationDuration: Double = 0.7
		static let springDamping: CGFloat = 0.4
		static let springVelocity: CGFloat = 0.5
	}
	
	enum PresentationStyle {
		case Small
		case Medium
		case Large
	}
	
	let contentView = UIView()
	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
	
	var contentViewHorizontalConstraint: NSLayoutConstraint!
	var presentationStyle: PresentationStyle
	
	init(style: PresentationStyle = .Small) {
		self.presentationStyle = style
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .clearColor()
		
		blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseModalViewController.close)))
		view.addSubview(blurView)
		
		contentView.backgroundColor = .whiteColor()
		contentView.layer.masksToBounds = true
		contentView.layer.cornerRadius = 2.5
		
		view.addSubview(contentView)
		
		addConstraints()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		contentViewHorizontalConstraint.constant = 0
		
		UIView.animateWithDuration(
			Constants.animationDuration,
			delay: 0,
			usingSpringWithDamping: Constants.springDamping,
			initialSpringVelocity: Constants.springVelocity,
			options: UIViewAnimationOptions(rawValue: 0),
			animations: {
				self.view.layoutIfNeeded()
			},
			completion: nil)
	}
	
	private func addConstraints() {
		blurView.autoPinEdgesToSuperviewEdges()
		
		let widthConstraint = contentView.autoSetDimension(.Width, toSize: 0)
		
		switch presentationStyle {
		case .Small:
			widthConstraint.constant = UIScreen.mainScreen().bounds.width * 0.6
		case .Medium:
			widthConstraint.constant = UIScreen.mainScreen().bounds.width * 0.75
		case .Large:
			widthConstraint.constant = UIScreen.mainScreen().bounds.width * 0.9
		}
		
		contentView.autoAlignAxisToSuperviewAxis(.Vertical)
		contentViewHorizontalConstraint = contentView.autoAlignAxisToSuperviewAxis(.Horizontal)
		contentViewHorizontalConstraint.constant = UIScreen.mainScreen().bounds.height/2
	}
	
	func close() {
		dismiss()
	}
	
	func dismiss(completion: ((() -> Void)?) = nil) {
		contentViewHorizontalConstraint.constant = UIScreen.mainScreen().bounds.height
		UIView.animateWithDuration(
			Constants.animationDuration,
			delay: 0,
			usingSpringWithDamping: Constants.springDamping,
			initialSpringVelocity: Constants.springVelocity,
			options: UIViewAnimationOptions(rawValue: 0),
			animations: {
				self.view.layoutIfNeeded()
			},
			completion: { finished in
				self.presentingViewController?.dismissViewControllerAnimated(false, completion: completion)
		})
	}
}
