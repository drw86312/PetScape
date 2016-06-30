//
//  ContactViewController.swift
//  PetScape
//
//  Created by David Warner on 6/28/16.
//  Copyright © 2016 drw. All rights reserved.
//

import UIKit
import MapKit
import PureLayout
import ReactiveCocoa
import WebImage

enum ContactAction {
	case Phone(String)
	case Email(String)
	case Link(NSURL)
}

protocol ContactViewControllerDelegate {
	func didSelectAction(action: ContactAction)
}

class ContactViewController: BaseModalViewController {
	
	let viewModel: ContactViewModel
	
	private let rootStackView = UIStackView()
	
	private let topStackView = UIStackView()
	private let imageView = UIImageView()
	private let titleLabel = UILabel()
	private let closeButton = UIButton()
	
	private let mapView = MKMapView()
	
	private let labelContainer = UIView()
	private let shelterNameLabel = UILabel()
	private let addressLabel = UILabel()
	private let distanceLabel = UILabel()
	
	private let bottomStackView = UIStackView()
	private let linkButton = UIButton()
	private let emailButton = UIButton()
	private let phoneButton = UIButton()

	var buttonHeight: NSLayoutConstraint!
	
	private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
	
	var delegate: ContactViewControllerDelegate?
	
	init(pet: Pet) {
		self.viewModel = ContactViewModel(pet: pet)
		super.init(style: .Large)
	}
	
	override func loadView() {
		super.loadView()
		
		rootStackView.axis = .Vertical
		rootStackView.distribution = .Fill
		rootStackView.alignment = .Fill
		rootStackView.spacing = 10;
		
		topStackView.axis = .Horizontal
		topStackView.distribution = .FillProportionally
		topStackView.alignment = .Fill
		topStackView.spacing = 10;
		
		imageView.layer.cornerRadius = 15
		imageView.layer.masksToBounds = true
		
		titleLabel.textColor = .darkGrayColor()
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .Center
		titleLabel.font = UIFont.boldSystemFontOfSize(19)
		
		closeButton.setBackgroundImage(UIColor.orangeColor().imageFromColor(), forState: .Normal)
		closeButton.addTarget(self, action: #selector(ContactViewController.close), forControlEvents: .TouchUpInside)
		
		topStackView.addArrangedSubview(imageView)
		topStackView.addArrangedSubview(titleLabel)
		topStackView.addArrangedSubview(closeButton)
		
		mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactViewController.mapViewPressed)))
		mapView.delegate = self
		
		shelterNameLabel.textColor = .darkGrayColor()
		shelterNameLabel.numberOfLines = 1
		shelterNameLabel.textAlignment = .Left
		shelterNameLabel.font = UIFont.boldSystemFontOfSize(19)
		labelContainer.addSubview(shelterNameLabel)
		
		addressLabel.textColor = .darkGrayColor()
		addressLabel.numberOfLines = 0
		addressLabel.textAlignment = .Left
		labelContainer.addSubview(addressLabel)
		
		distanceLabel.textColor = .darkGrayColor()
		distanceLabel.textAlignment = .Right
		distanceLabel.numberOfLines = 1
		distanceLabel.font = UIFont.systemFontOfSize(12)
		labelContainer.addSubview(distanceLabel)
		
		bottomStackView.axis = .Horizontal
		bottomStackView.distribution = .EqualCentering
		bottomStackView.alignment = .Fill
		bottomStackView.spacing = 10;
		
		linkButton.setTitle("Li", forState: .Normal)
		linkButton.setBackgroundImage(UIColor.greenColor().imageFromColor(), forState: .Normal)
		linkButton.addTarget(self, action: #selector(ContactViewController.linkButtonPressed), forControlEvents: .TouchUpInside)
		
		emailButton.setTitle("Em", forState: .Normal)
		emailButton.setBackgroundImage(UIColor.blueColor().imageFromColor(), forState: .Normal)
		emailButton.addTarget(self, action: #selector(ContactViewController.emailButtonPressed), forControlEvents: .TouchUpInside)
		
		phoneButton.setTitle("Ph", forState: .Normal)
		phoneButton.setBackgroundImage(UIColor.yellowColor().imageFromColor(), forState: .Normal)
		phoneButton.addTarget(self, action: #selector(ContactViewController.phoneButtonPressed), forControlEvents: .TouchUpInside)

		bottomStackView.addArrangedSubview(linkButton)
		bottomStackView.addArrangedSubview(emailButton)
		bottomStackView.addArrangedSubview(phoneButton)
		
		rootStackView.addArrangedSubview(topStackView)
		rootStackView.addArrangedSubview(mapView)
		rootStackView.addArrangedSubview(labelContainer)
		rootStackView.addArrangedSubview(bottomStackView)
		
		contentView.addSubview(rootStackView)
		
		spinner.hidesWhenStopped = true
		spinner.color = UIColor(color: .MainColor)
		view.addSubview(spinner)
		
		addConstraints()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		DynamicProperty(object: self.titleLabel,
		                keyPath: "text") <~ viewModel
							.titleString
							.producer
							.observeOn(UIScheduler())
							.map { return $0 }
		
		DynamicProperty(object: self.shelterNameLabel,
		                keyPath: "text") <~ viewModel
							.shelterName
							.producer
							.observeOn(UIScheduler())
							.map { return $0 }
		
		DynamicProperty(object: self.addressLabel,
		                keyPath: "text") <~ viewModel
							.shelterAddress
							.producer
							.observeOn(UIScheduler())
							.map { return $0 }
		
		DynamicProperty(object: self.distanceLabel,
		                keyPath: "text") <~ viewModel
							.distance
							.producer
							.observeOn(UIScheduler())
							.map { if let d = $0 { return String(format:"%.1f mi.", d) } else { return "" }}
		
		DynamicProperty(object: self.phoneButton,
		                keyPath: "enabled") <~ viewModel
							.phone
							.producer
							.observeOn(UIScheduler())
							.map { $0 != nil }
		
		DynamicProperty(object: self.emailButton,
		                keyPath: "enabled") <~ viewModel
							.email
							.producer
							.observeOn(UIScheduler())
							.map { $0 != nil }
		
		DynamicProperty(object: self.linkButton,
		                keyPath: "enabled") <~ viewModel
							.link
							.producer
							.observeOn(UIScheduler())
							.map { $0 != nil }
		
		viewModel.userLocation.producer
			.combineLatestWith(viewModel.shelterLocation.producer)
			.observeOn(UIScheduler())
			.startWithNext { [unowned self] (user, shelter) in
				var annotations: [MKPointAnnotation] = []
				
				if let user = user {
					let userAnnotation = MKPointAnnotation()
					userAnnotation.coordinate = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
					userAnnotation.title = "You"
					annotations.append(userAnnotation)
				}
				
				if let shelter = shelter {
					let shelterAnnotation = MKPointAnnotation()
					shelterAnnotation.coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
					shelterAnnotation.title = self.viewModel.shelterName.value
					annotations.append(shelterAnnotation)
				}
				
				self.mapView.removeAnnotations(self.mapView.annotations)
				var mapRect = MKMapRectNull
				
				annotations.forEach {
					self.mapView.addAnnotation($0)
					let point = MKMapPointForCoordinate($0.coordinate)
					let rect  = MKMapRectMake(point.x, point.y , 0, 0)
					mapRect = MKMapRectUnion(mapRect, rect)
				}
				self.mapView.setVisibleMapRect(mapRect,
					edgePadding: UIEdgeInsetsMake(15, 5, 15, 5),
					animated: true)
		}
		
		viewModel
			.imageURL
			.producer
			.observeOn(UIScheduler())
			.startWithNext { [unowned self] url in
				self.imageView.sd_setImageWithURL(url,
					placeholderImage: UIColor.darkGrayColor().imageFromColor())
		}
		
	}
	
	 private func addConstraints() {
		rootStackView.autoPinEdgesToSuperviewMargins()
		
		bottomStackView.arrangedSubviews.forEach {
			$0.autoSetDimension(.Width, toSize: 50)
			$0.autoSetDimension(.Height, toSize: 50)
		}
		
		imageView.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
		closeButton.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
		
		mapView.autoSetDimension(.Height, toSize: 200)
		
		shelterNameLabel.autoPinEdge(.Top, toEdge: .Top, ofView: labelContainer)
		shelterNameLabel.autoPinEdge(.Left, toEdge: .Left, ofView: labelContainer)
		shelterNameLabel.autoSetDimension(.Width, toSize: 250)
		
		addressLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: shelterNameLabel)
		addressLabel.autoPinEdge(.Left, toEdge: .Left, ofView: labelContainer)
		addressLabel.autoSetDimension(.Width, toSize: 250)
		
		distanceLabel.autoPinEdge(.Right, toEdge: .Right, ofView: labelContainer)
		distanceLabel.autoPinEdge(.Top, toEdge: .Top, ofView: labelContainer)
		distanceLabel.autoPinEdge(.Left, toEdge: .Right, ofView: addressLabel)
		
		spinner.autoCenterInSuperview()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func linkButtonPressed() {
		guard let delegate = delegate, let link = viewModel.link.value else { return }
		dismiss { delegate.didSelectAction(.Link(link)) }
	}
	
	func emailButtonPressed() {
		guard let delegate = delegate, let email = viewModel.email.value else { return }
		let stripped = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		dismiss { delegate.didSelectAction(.Email(stripped)) }
	}
	
	func phoneButtonPressed() {
		guard let delegate = delegate, let phone = viewModel.phone.value else { return }
		let stripped = "tel://" + phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
		dismiss { delegate.didSelectAction(.Phone(stripped)) }
	}
	
	func mapViewPressed() {
//		buttonHeight.constant = 0
//		
//		UIView.animateWithDuration(
//			Constants.animationDuration,
//			delay: 0,
//			usingSpringWithDamping: Constants.springDamping,
//			initialSpringVelocity: Constants.springVelocity,
//			options: UIViewAnimationOptions(rawValue: 0),
//			animations: {
//				self.view.layoutIfNeeded()
//			},
//			completion: nil)
	}
}

extension ContactViewController: MKMapViewDelegate {
	
}
