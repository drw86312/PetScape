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

extension LocationManager.LocationStatus: Equatable {}

func == (lhs: LocationManager.LocationStatus, rhs: LocationManager.LocationStatus) -> Bool {
	switch (lhs, rhs) {
	case (.NotDetermined, .NotDetermined):
		return true
	case (.Denied, .Denied):
		return true
	case (.Scanning, .Scanning):
		return true
	case (.Some(let x), .Some(let y)):
		return x == y
	case (.Error(let x), .Error(let y)):
		return x == y
	default: return false
	}
}

class LocationManager: NSObject, CLLocationManagerDelegate {
	
	enum LocationStatus {
		case NotDetermined
		case Denied
		case Scanning
		case Some(String)
		case Error(String)
	}
	
	let manager = CLLocationManager()
	private let _locationStatusProperty = MutableProperty<LocationStatus>(.NotDetermined)
	let locationStatusProperty: AnyProperty<LocationStatus>
	let userCoordinate = MutableProperty<CLLocationCoordinate2D?>(nil)
	
	override init() {
		locationStatusProperty = AnyProperty(_locationStatusProperty)
		super.init()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.requestWhenInUseAuthorization()
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		manager.stopUpdatingLocation()
		guard let location = manager.location else {
			self._locationStatusProperty.value = .Error("No locations found")
			return
		}
		
		CLGeocoder().reverseGeocodeLocation(location, completionHandler: { [unowned self ] placemarks, error -> Void in
			if let error = error {
				self._locationStatusProperty.value = .Error(error.localizedDescription)
			}
			
			guard let placemarks = placemarks where placemarks.count > 0, let placemark = placemarks.first else {
				self._locationStatusProperty.value = .Error("No locations found")
				return
			}
			
			if let coordinate = placemark.location?.coordinate {
				self.userCoordinate.value = coordinate
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
	
	func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
		self._locationStatusProperty.value = .Scanning
	}
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		switch status {
		case .AuthorizedAlways, .AuthorizedWhenInUse:
			scanLocation()
		case .Denied, .Restricted:
			self._locationStatusProperty.value = .Denied
		case .NotDetermined:
			self._locationStatusProperty.value = .NotDetermined
		}
	}
	
	func scanLocation() {
		manager.startUpdatingLocation()
	}
	
	func forceSetLocation(location: String) {
		if case .Some(let currentLocation) = locationStatusProperty.value {
			if currentLocation != location {
				_locationStatusProperty.value = .Some(location)
			}
		} else {
			_locationStatusProperty.value = .Some(location)
		}
	}
}
