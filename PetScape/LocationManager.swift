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
		case None
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
	private let _locationStatusProperty = MutableProperty<LocationStatus>(.None)
	let locationStatusProperty: AnyProperty<LocationStatus>
	
	override init() {
		locationStatusProperty = AnyProperty(_locationStatusProperty)
		super.init()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		manager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			manager.startUpdatingLocation()
		}
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
		if status == .AuthorizedAlways {
			if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
				if CLLocationManager.isRangingAvailable() {
					// do stuff
				}
			}
		}
	}
}
