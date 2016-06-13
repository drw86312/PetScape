//
//  API.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Alamofire
import Argo

enum Error: ErrorType {
	case Underlying(NSError)
	case Decoding(DecodeError)
	case JSONParsing(NSError)
	case Unknown
}

struct API {
	
	static let baseURL = NSURL(string: "https://api.petfinder.com/")!
	static let clientID = "d8e2be636623a3c2ebf10ae24bf5dfe2"
	static let clientSecret = "15b235b489fe9628b83d92b2a1d2f611"
	
	static let kAPIOutput = "output"
	static let kAPIOutputDefaultValue = "full"
	
	static let kAPIFormat = "format"
	static let kAPIFormatDefaultValue = "json"

	static func fetch<Model: Decodable where Model.DecodedType == Model>(
		endpoint: Endpoint<Model>,
		queue: dispatch_queue_t? = nil,
		completionHandler: Response<Model, Error> -> Void) {
		request(endpoint)
			.response(queue: queue,
			          responseSerializer: Request.ArgoResponseSerializer(endpoint.keyPath),
			          completionHandler: completionHandler)
	}
	
	static func fetch<Model: Decodable where Model.DecodedType == Model>(
		endpoint: Endpoint<[Model]>,
		queue: dispatch_queue_t? = nil,
		completionHandler: Response<[Model], Error> -> Void) {
		let req = request(endpoint)
		req.response(queue: queue,
		             responseSerializer: Request.ArgoResponseSerializer(endpoint.keyPath),
		             completionHandler: completionHandler)
	}
}

extension Request {
	static func ArgoResponseSerializer
		<Model: Decodable where Model.DecodedType == Model>(keyPath: String) -> ResponseSerializer<Model, Error> {
		return ResponseSerializer { request, response, data, error in
			if let error = error {
				return .Failure(.Underlying(error))
			}
			
			let JSONSerializer = Request.JSONResponseSerializer()
			switch JSONSerializer.serializeResponse(request, response, data, error) {
				
			case .Success(let jsonObject):
				guard let modelObject = jsonObject.valueForKeyPath(keyPath) else {
					return .Failure(.Unknown)
				}
				
				let decodedModel: Decoded<Model> = decode(modelObject) as Decoded<Model>
				switch decodedModel {
				case .Success(let model):
					return .Success(model)
				case .Failure(let decodeError):
					return .Failure(.Decoding(decodeError))
				}
			case .Failure(let error):
				return .Failure(.JSONParsing(error))
			}
		}
	}
	
	static func ArgoResponseSerializer
		<Model: Decodable where Model.DecodedType == Model>(keyPath: String) -> ResponseSerializer<[Model], Error> {
		return ResponseSerializer { _, _, data, error in
			if let error = error {
				return .Failure(.Underlying(error))
			}
			guard let data = data else { return .Failure(.Unknown) }
			do {
				let object = try NSJSONSerialization.JSONObjectWithData(data, options: [])
				print(object)
				switch decode(object) as Decoded<[Model]> {
				case .Success(let models):
					return .Success(models)
				case .Failure(let error):
					return .Failure(.Decoding(error))
				}
			} catch let error as NSError {
				return .Failure(.JSONParsing(error))
			}
		}
	}
}
