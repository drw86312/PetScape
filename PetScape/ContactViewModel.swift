//
//  ContactViewModel.swift
//  PetScape
//
//  Created by David Warner on 6/28/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import ReactiveCocoa
import MapKit

class ContactViewModel {
	
	let pet: Pet
	var fetchShelter: Action<Pet, Shelter, Error>!
	var userCoordinate: CLLocationCoordinate2D?
	
	init(pet: Pet) {
		
		self.pet = pet
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		userCoordinate = appDelegate.locationManager.userCoordinate.value
		
		self.fetchShelter = Action<Pet, Shelter, Error> { pet in
			
			return SignalProducer<Shelter, Error> { observer, disposable in
				guard let shelterID = pet.shelterID else {
					observer.sendFailed(.Unknown)
					return
				}
				
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
		}
	}
}
