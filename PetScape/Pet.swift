//
//  Pet.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Argo
import Curry
import Foundation

struct Pet {
	let id: Int
	let lastUpdated: NSDate?
	let mix: Bool?
	let photos: [Photo]?
	let breeds: [String]?
	let description: String?
	let animal: Animal?
	let age: Age?
	let sex: Sex?
	let size: Size?
	let contact: Contact?
	let name: String?
	let shelterID: String?
	let shelterPetID: String?
	let adoptionStatus: AdoptionStatus?
}

extension Pet: Decodable {
	static func decode(json: JSON) -> Decoded<Pet> {
		
		let breeds: Decoded<[String]> = decodedJSON(json, forKey: "breeds")
			.map { decodedJSON($0, forKey: "breed") }
			.flatMap { breedJSON in
				return breedJSON.map { json in
					switch json {
					case .Array(let breedsArrayJSON):
						return breedsArrayJSON.map { json in
							switch json {
							case .Object(let breedsToJSON):
								switch breedsToJSON["$t"]! {
								case .String(let breed):
									return breed
								default: return ""
								}
							default: return ""
							}
						}
					case .Object(let breedsToJSON):
						switch breedsToJSON["$t"]! {
						case .String(let breed):
							return [breed]
						default: return []
						}
					default: return []
					}
				}
		}
		
		let partialPet = curry(Pet.init)
			<^> (json <| ["id", "$t"] >>- toInt)
			<*> (json <| ["lastUpdate", "$t"] >>- toNSDate)
			<*> (json <| ["mix", "$t"] >>- toBoolean)
			<*> (json <|| ["media", "photos", "photo"] >>- toPhotosArray)
			<*> breeds
			<*> json <|? ["description", "$t"]
			<*> json <|? ["animal", "$t"]
			<*> json <|? ["age", "$t"]
		return partialPet
			<*> json <|? ["sex", "$t"]
			<*> json <|? ["size", "$t"]
			<*> json <|? ["contact"]
			<*> json <|? ["name", "$t"]
			<*> json <|? ["shelterId", "$t"]
			<*> json <|? ["shelterPetId", "$t"]
			<*> json <|? ["status", "$t"]
	}
}


//func toBreeds(json: JSON) -> Decoded<[String]> {
//	var breeds: [String] = ["hello"]
//	return .fromOptional(breeds)
//}

// Options are keyword descriptors (ex. "hasShots", "housetrained", "specialNeeds", etc.)
//	let options: [String]?
//	let breeds: [String]?

//			<*> json <||? ["options", "option"]
