//
//  Argo+Decode.swift
//  PetScape
//
//  Created by David Warner on 6/12/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Foundation

extension URL: Decodable {
	public static func decode(_ json: JSON) -> Decoded<URL> {
		return String.decode(json)
			.flatMap {
				return URL(string: $0).map(pure) ?? .typeMismatch("NSURL", actual: "String")
		}
	}
}

func toInt(_ number: String) -> Decoded<Int> {
	return .fromOptional(Int(number))
}

func toFloat(_ number: String) -> Decoded<Float> {
	return .fromOptional(Float(number))
}

func toBoolean(_ string: String) -> Decoded<Bool> {
	return .fromOptional(string.lowercased() == "yes")
}

func toNSDate(_ dateString: String) -> Decoded<Date> {
	let jsonDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		return dateFormatter
	}()
	return .fromOptional(jsonDateFormatter.date(from: dateString))
}

func toPhotos(_ images: [Image]?) -> Decoded<[Photo]> {
	var photos: [Photo] = []
	
	guard let images = images else { return .fromOptional(photos) }
		
	// Get an array of unique image IDs (these will essentially become photos)
	Set(images.map { $0.id }).forEach { id in
		
		// Get all images associated with a particular image ID.
		let associatedImages = images.filter { $0.id == id }
		
		// If associatedImages, iterate and store URLs of various sizes in local vars
		if associatedImages.count > 0 {
			var thumbnailURL: URL?
			var smallURL: URL?
			var mediumURL: URL?
			var largeURL: URL?
			var extraLargeURL: URL?
			
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
