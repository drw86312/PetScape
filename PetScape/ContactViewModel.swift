//
//  ContactViewModel.swift
//  PetScape
//
//  Created by David Warner on 6/28/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import MapKit

class ContactViewModel {
	
	let imageURL = MutableProperty<NSURL?>(nil)
	let titleString = MutableProperty<String?>(nil)
	
	let shelterName = MutableProperty<String?>(nil)
	let shelterAddress = MutableProperty<String?>(nil)
	let distance = MutableProperty<Double?>(nil)
	
	let userLocation: MutableProperty<CLLocationCoordinate2D?>
	let shelterLocation = MutableProperty<CLLocationCoordinate2D?>(nil)
	
	let email = MutableProperty<String?>(nil)
	let phone = MutableProperty<String?>(nil)
	let link = MutableProperty<String?>(nil)
	
	init(pet: Pet) {
		
		self.imageURL.value = pet.photos?.first?.thumbnailURL
		self.titleString.value = pet.name
		self.email.value = pet.contact?.email
		self.phone.value = pet.contact?.phone
		
		self.userLocation = (UIApplication.sharedApplication().delegate as! AppDelegate).locationManager.userCoordinate
		
		guard let shelterID = pet.shelterID else { return }
		
		let shelter = SignalProducer<Shelter, Error> { observer, _ in
			API.fetch(Endpoint<Shelter>.getShelter(shelterID)) { response in
				switch response.result {
				case .Success(let shelter):
					observer.sendNext(shelter)
					observer.sendCompleted()
				case .Failure(let error):
					observer.sendFailed(error)
				}
			}
			}
			.producer
			.flatMapError { _ in SignalProducer<Shelter, NoError>.empty }
		
		shelterName <~ shelter.map { $0.name }
		shelterAddress <~ shelter.map { $0.contact?.formattedAddressString() }
		
		shelterLocation <~ shelter
			.map { shelter -> CLLocationCoordinate2D? in
				guard let lat = shelter.latitude, let long = shelter.longitude else { return nil }
				return CLLocationCoordinate2D(latitude: lat, longitude: long)
		}
		
		distance <~ userLocation
			.producer
			.map { coordinate -> CLLocation? in
				guard let coordinate = coordinate else { return nil }
				return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			}
			.combineLatestWith(shelter
				.map { shelter -> CLLocation? in
					guard let lat = shelter.latitude, let long = shelter.longitude else { return nil }
					return CLLocation(latitude: lat, longitude: long)
				})
			.map { user, shelter in
				guard let user = user, let shelter = shelter else { return nil }
				return shelter.distanceFromLocation(user) * 0.000621371
			}
			.skipRepeats(==)
	}
}
