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
	
		let photos: Decoded<[Image]> = decodedJSON(json, forKey: "media")
			.map { decodedJSON($0, forKey: "photos") }
			.flatMap { photoJSON in
				return photoJSON.map { json in
					switch json {
					case .Object(let photoToJSON):
						switch photoToJSON["photo"]! {
						case .Array(let arrayJSON):
							return arrayJSON.map { json in
								switch json {
								case .Object(let imageJSON):
									
									var id: Int?
									var url: NSURL?
									var size: String?
									
									switch imageJSON["@id"]! {
									case .String(let string):
										if let int = Int(string) {
											id = int
										}
									default: break
									}
									
									switch imageJSON["$t"]! {
									case .String(let string):
										if let urlFromString = NSURL(string: string) {
											url = urlFromString
										}
									default: break
									}
									
									switch imageJSON["@size"]! {
									case .String(let string):
										size = string
									default: break
									}
									
									if let id = id,
										let url = url,
										let size = size {
										return Image(id: id, url: url, size: size)
									}
									return Image(id: 5000, url: NSURL(), size: "failure")
								default:
									return Image(id: 5000, url: NSURL(), size: "failure")
								}
							}
						default:
							return []
						}
					default:
						return []
					}
				}
		}
		
		let partialPet = curry(Pet.init)
			<^> (json <| ["id", "$t"] >>- toInt)
			<*> (json <| ["lastUpdate", "$t"] >>- toNSDate)
			<*> (json <| ["mix", "$t"] >>- toBoolean)
			<*> (photos >>- toPhotosArray)
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
