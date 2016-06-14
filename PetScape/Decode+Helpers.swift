//
//  Argo+Decode.swift
//  PetScape
//
//  Created by David Warner on 6/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

extension NSURL: Decodable {
	public static func decode(json: JSON) -> Decoded<NSURL> {
		return String.decode(json)
			.flatMap {
				return NSURL(string: $0).map(pure) ?? .typeMismatch("NSURL", actual: "String")
		}
	}
}

func toInt(number: String) -> Decoded<Int> {
	return .fromOptional(Int(number))
}

func toFloat(number: String) -> Decoded<Float> {
	return .fromOptional(Float(number))
}

func toBoolean(string: String) -> Decoded<Bool> {
	return .fromOptional(string.lowercaseString == "yes")
}

func toNSDate(dateString: String) -> Decoded<NSDate> {
	let jsonDateFormatter: NSDateFormatter = {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return dateFormatter
	}()
	return .fromOptional(jsonDateFormatter.dateFromString(dateString))
}


func toPhotosArray(images: [Image]) -> Decoded<[Photo]> {
	var photos: [Photo] = []
	
	// Get an array of unique image IDs (these will essentially become photos)
	Array(Set(images.map { $0.id })).forEach { id in
		
		// Get all images associated with a particular image ID.
		let associatedImages = images.filter { $0.id == id }
		
		// If associatedImages, iterate and store URLs of various sizes in local vars
		if associatedImages.count > 0 {
			var thumbnailURL: NSURL?
			var smallURL: NSURL?
			var mediumURL: NSURL?
			var largeURL: NSURL?
			var extraLargeURL: NSURL?
			associatedImages.forEach {
				switch $0.size {
				case "t":
					thumbnailURL = $0.url
				case "pnt":
					smallURL = $0.url
				case "fpm":
					mediumURL = $0.url
				case "pn":
					largeURL = $0.url
				case "x":
					extraLargeURL = $0.url
				default : return
				}
			}
			
			// Initialize a photo and add it to array
			photos.append(
				Photo(id: id,
					thumbnailURL: thumbnailURL,
					smallURL: smallURL, mediumURL: mediumURL,
					largeURL: largeURL,
					extraLargeURL: extraLargeURL))
		}
	}
	return .fromOptional(photos)
}
