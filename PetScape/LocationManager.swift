//
//  LocationManager.swift
//  PetScape
//
//  Created by David Warner on 6/20/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveCocoa

class LocationManager: NSObject, CLLocationManagerDelegate {
	
	enum LocationStatus {
		case NotDetermined
		case Denied
		case Some(String)
		case Error(String)
	}
	
	class var sharedInstance : LocationManager {
		struct Static {
			static let instance : LocationManager = LocationManager()
		}
		return Static.instance
	}
	
	let manager = CLLocationManager()
	private let _locationStatusProperty = MutableProperty<LocationStatus>(.NotDetermined)
	let locationStatusProperty: AnyProperty<LocationStatus>
	
	override init() {
		locationStatusProperty = AnyProperty(_locationStatusProperty)
		super.init()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		manager.requestWhenInUseAuthorization()
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = manager.location else {
			self._locationStatusProperty.value = .Error("No locations found")
			return
		}
		
		CLGeocoder().reverseGeocodeLocation(location, completionHandler: { [unowned self ] (placemarks, error) -> Void in
			manager.stopUpdatingLocation()
			if let error = error {
				self._locationStatusProperty.value = .Error(error.localizedDescription)
			}
			
			guard let placemarks = placemarks where placemarks.count > 0,
				  let placemark = placemarks.first else {
					self._locationStatusProperty.value = .Error("No locations found")
					return
			}
			
			// Give postal code precedence, then try city/state
			if let postalCode = placemark.postalCode {
				self._locationStatusProperty.value = .Some(postalCode)
			} else if let locality = placemark.locality,
				      let administrativeArea = placemark.administrativeArea {
				self._locationStatusProperty.value = .Some(locality + ", " + administrativeArea)
			} else {
				self._locationStatusProperty.value = .Error("No locations found")
			}
		})
	}
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		switch status {
		case .AuthorizedAlways, .AuthorizedWhenInUse:
			manager.startUpdatingLocation()
		case .Denied, .Restricted:
			self._locationStatusProperty.value = .Denied
		case .NotDetermined:
			self._locationStatusProperty.value = .NotDetermined
		}
	}
}

//case NotDetermined
//
//// This application is not authorized to use location services.  Due
//// to active restrictions on location services, the user cannot change
//// this status, and may not have personally denied authorization
//case Restricted
//
//// User has explicitly denied authorization for this application, or
//// location services are disabled in Settings.
//case Denied
//
//// User has granted authorization to use their location at any time,
//// including monitoring for regions, visits, or significant location changes.
//@available(iOS 8.0, *)
//case AuthorizedAlways
//
//// User has granted authorization to use their location only when your app
//// is visible to them (it will be made visible to them if you continue to
//// receive location updates while in the background).  Authorization to use
//// launch APIs has not been granted.
//@available(iOS 8.0, *)
//case AuthorizedWhenInUse
