//
//  Request+ArgoResponseSerializer.swift
//  PetScape
//
//  Created by David Warner on 6/13/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Alamofire
import Argo

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
				print(jsonObject)
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
		return ResponseSerializer { request, response, data, error in
			if let error = error {
				return .Failure(.Underlying(error))
			}
			
			let JSONSerializer = Request.JSONResponseSerializer()
			switch JSONSerializer.serializeResponse(request, response, data, error) {
			case .Success(let jsonObject):
				print(jsonObject)
				guard let modelObject = jsonObject.valueForKeyPath(keyPath) else {
					return .Failure(.Unknown)
				}
				
				let decodedModels: Decoded<[Model]> = decode(modelObject) as Decoded<[Model]>
				switch decodedModels {
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
}
