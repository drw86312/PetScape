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
	case Link(String)
}

protocol ContactViewControllerDelegate {
	func didSelectAction(action: ContactAction)
}

class ContactViewController: BaseModalViewController {
	
	let viewModel: ContactViewModel
	
	let rootStackView = UIStackView()
	
	let topStackView = UIStackView()
	let petImageView = UIImageView()
	let titleLabel = UILabel()
	let closeButton = UIButton()
	
	let mapView = MKMapView()
	
	let labelContainer = UIView()
	let addressLabel = UILabel()
	let distanceLabel = UILabel()
	
	let bottomStackView = UIStackView()
	var buttonHeight: NSLayoutConstraint!
	
	let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
	
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
		
		petImageView.layer.cornerRadius = 15
		petImageView.layer.masksToBounds = true
		petImageView.sd_setImageWithURL(viewModel.pet.photos?.first?.thumbnailURL,
		                                placeholderImage: UIColor.darkGrayColor().imageFromColor())
		
		titleLabel.textColor = .darkGrayColor()
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .Center
		titleLabel.font = UIFont.boldSystemFontOfSize(19)
		titleLabel.text = viewModel.pet.name
		
		closeButton.setBackgroundImage(UIColor.orangeColor().imageFromColor(), forState: .Normal)
		closeButton.addTarget(self, action: #selector(ContactViewController.dismiss), forControlEvents: .TouchUpInside)
		
		topStackView.addArrangedSubview(petImageView)
		topStackView.addArrangedSubview(titleLabel)
		topStackView.addArrangedSubview(closeButton)
		
		mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactViewController.mapViewPressed)))
		mapView.delegate = self
		
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
		
		let link = UIButton()
		link.setTitle("A", forState: .Normal)
		link.setBackgroundImage(UIColor.greenColor().imageFromColor(), forState: .Normal)
		link.addTarget(self, action: #selector(ContactViewController.linkButtonPressed), forControlEvents: .TouchUpInside)
		
		let email = UIButton()
		email.setTitle("B", forState: .Normal)
		email.setBackgroundImage(UIColor.blueColor().imageFromColor(), forState: .Normal)
		email.addTarget(self, action: #selector(ContactViewController.emailButtonPressed), forControlEvents: .TouchUpInside)
		
		let phone = UIButton()
		phone.setTitle("C", forState: .Normal)
		phone.setBackgroundImage(UIColor.yellowColor().imageFromColor(), forState: .Normal)
		phone.addTarget(self, action: #selector(ContactViewController.phoneButtonPressed), forControlEvents: .TouchUpInside)

		bottomStackView.addArrangedSubview(link)
		bottomStackView.addArrangedSubview(email)
		bottomStackView.addArrangedSubview(phone)
		
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
		
		viewModel
			.fetchShelter
			.events
			.observeOn(UIScheduler())
			.observeNext { [unowned self] event in
				if case .Next(let shelter) = event {
					self.configureMapView(shelter)
					self.configureAddressLabel(shelter)
				}
		}
		
		viewModel.fetchShelter.apply(viewModel.pet).start()
		spinner.loading(viewModel.fetchShelter.executing.signal)
	}
	
	 private func addConstraints() {
		rootStackView.autoPinEdgesToSuperviewMargins()
		
		bottomStackView.arrangedSubviews.forEach {
			$0.autoSetDimension(.Width, toSize: 50)
			$0.autoSetDimension(.Height, toSize: 50)
		}
		
		petImageView.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
		closeButton.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
		
		mapView.autoSetDimension(.Height, toSize: 200)
		
		addressLabel.autoPinEdge(.Top, toEdge: .Top, ofView: labelContainer)
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
		guard let delegate = delegate  else { return }
		delegate.didSelectAction(.Link("link"))
	}
	
	func emailButtonPressed() {
		guard let delegate = delegate else { return }
		delegate.didSelectAction(.Email("email"))
	}
	
	func phoneButtonPressed() {
		guard let delegate = delegate else { return }
		delegate.didSelectAction(.Phone("phone"))
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
	
	private func configureAddressLabel(shelter: Shelter) {
		
		let titleText = shelter.name.characters.count > 0 ? shelter.name + "\n" : ""
		
		let attrText = NSMutableAttributedString(string: titleText, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(19)])
		let addressString = NSMutableAttributedString(string: shelter.contact.formattedAddressString(), attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14)])
		attrText.appendAttributedString(addressString)
		
		addressLabel.attributedText = attrText
	}
	
	private func configureMapView(shelter: Shelter) {
		
		mapView.removeAnnotations(mapView.annotations)
		var annotations: [MKPointAnnotation] = []
		
		let shelterAnnotation = MKPointAnnotation()
		shelterAnnotation.coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
		shelterAnnotation.title = shelter.name
		
		annotations.append(shelterAnnotation)
		
		if let userCoordinate = viewModel.userCoordinate {
			let userAnnotation = MKPointAnnotation()
			userAnnotation.coordinate = userCoordinate
			userAnnotation.title = "Your Location"
			annotations.append(userAnnotation)
			
			let location = CLLocation(latitude: shelter.latitude, longitude: shelter.longitude)
			let location2 = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
			let distance = location.distanceFromLocation(location2)
			
			distanceLabel.text = String(format:"%.1f mi.", distance * 0.000621371)
		}
		
		var mapRect = MKMapRectNull
		
		annotations.forEach {
			self.mapView.addAnnotation($0)
			let point = MKMapPointForCoordinate($0.coordinate)
			let rect  = MKMapRectMake(point.x, point.y , 0, 0)
			mapRect = MKMapRectUnion(mapRect, rect)
		}
		self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsetsMake(15, 5, 15, 5), animated: true)
	}
}

extension ContactViewController: MKMapViewDelegate {
	
}
