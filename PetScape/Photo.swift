//
//  Photo.swift
//  PetScape
//
//  Created by David Warner on 6/11/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry

struct Photo {
	let id: Int
	let thumbnailURL: URL?
	let smallURL: URL?
	let mediumURL: URL?
	let largeURL: URL?
	let extraLargeURL: URL?
}

// Image is an intermediate object which will be mapped to Photo with -toPhotos function b/c JSON format is weird 
struct Image {
	let id: Int
	let url: URL
	let size: String
}

extension Image: Decodable {
	static func decode(_ json: JSON) -> Decoded<Image> {
		let image = curry(Image.init)
			<^> (json <| ["@id"] >>- toInt)
			<*> json <| ["$t"]
			<*> json <| ["@size"]
		return image
	}
}
