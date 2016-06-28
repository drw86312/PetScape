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

class ContactViewController: BaseModalViewController {
	
	let viewModel: ContactViewModel
	
	let mainStackView = UIStackView()
	
	let mapView = MKMapView()
	
	let labelContainer = UIView()
	let addressLabel = UILabel()
	let distanceLabel = UILabel()
	
	let buttonsStackView = UIStackView()
	
	var buttonHeight: NSLayoutConstraint!
	
	init(pet: Pet) {
		self.viewModel = ContactViewModel(pet: pet)
		super.init(style: .Large)
	}
	
	override func loadView() {
		super.loadView()
		
		mainStackView.axis = .Vertical
		mainStackView.distribution = .Fill
		mainStackView.alignment = .Fill
		mainStackView.spacing = 10;
		
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
		
		buttonsStackView.axis = .Horizontal
		buttonsStackView.distribution = .EqualCentering
		buttonsStackView.alignment = .Fill
		buttonsStackView.spacing = 10;
		
		let button1 = UIButton()
		button1.setTitle("A", forState: .Normal)
		button1.setBackgroundImage(UIColor.greenColor().imageFromColor(), forState: .Normal)
		
		let button2 = UIButton()
		button2.setTitle("B", forState: .Normal)
		button2.setBackgroundImage(UIColor.blueColor().imageFromColor(), forState: .Normal)
		
		let button3 = UIButton()
		button3.setTitle("C", forState: .Normal)
		button3.setBackgroundImage(UIColor.yellowColor().imageFromColor(), forState: .Normal)

		buttonsStackView.addArrangedSubview(button1)
		buttonsStackView.addArrangedSubview(button2)
		buttonsStackView.addArrangedSubview(button3)
		
		mainStackView.addArrangedSubview(mapView)
		mainStackView.addArrangedSubview(labelContainer)
		mainStackView.addArrangedSubview(buttonsStackView)
		
		contentView.addSubview(mainStackView)
		
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
					print(shelter.contact)
				}
		}
		
		viewModel.fetchShelter.apply(viewModel.pet).start()
	}
	
	 private func addConstraints() {
		mainStackView.autoPinEdgesToSuperviewMargins()
		
		buttonsStackView.arrangedSubviews.forEach {
			$0.autoSetDimension(.Width, toSize: 50)
			$0.autoSetDimension(.Height, toSize: 50)
		}
		
		mapView.autoSetDimension(.Height, toSize: 200)
		
		addressLabel.autoPinEdge(.Top, toEdge: .Top, ofView: labelContainer)
		addressLabel.autoPinEdge(.Left, toEdge: .Left, ofView: labelContainer)
		addressLabel.autoSetDimension(.Width, toSize: 250)
		
		distanceLabel.autoPinEdge(.Right, toEdge: .Right, ofView: labelContainer)
		distanceLabel.autoPinEdge(.Top, toEdge: .Top, ofView: labelContainer)
		distanceLabel.autoPinEdge(.Left, toEdge: .Right, ofView: addressLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		
		var total: String = ""
		
		var address = shelter.contact.address1 ?? ""
		let address2 = shelter.contact.address2 ?? ""
		if address2.characters.count > 0 { address += ", " + address2 } else { address += address2 }
		
		total = address
		if total.characters.count > 0 { total += "\n" }
		
		var city = shelter.contact.city ?? ""
		let state = shelter.contact.state ?? ""
		if state.characters.count > 0 { city += ", " + state } else { city += state }
		
		total += city
		if total.characters.count > 0 { total += "\n" }
		
		var country = shelter.contact.country ?? ""
		let zip = shelter.contact.zip ?? ""
		if zip.characters.count > 0 { country += " " + zip } else { country += zip }
		
		total += country
		
		
		let attrText = NSMutableAttributedString(string: titleText, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(19)])
		let addressString = NSMutableAttributedString(string: total, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14)])
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
