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
		<Model: Decodable where Model.DecodedType == Model>(_ keyPath: String) -> ResponseSerializer<Model, Error> {
		return ResponseSerializer { request, response, data, error in
			if let error = error {
				return .failure(.underlying(error))
			}
			
			let JSONSerializer = Request.JSONResponseSerializer()
			switch JSONSerializer.serializeResponse(request, response, data, error) {
				
			case .success(let jsonObject):
				guard let modelObject = jsonObject.value(forKeyPath: keyPath) else {
					return .failure(.unknown)
				}
				
				let decodedModel: Decoded<Model> = decode(modelObject) as Decoded<Model>
				switch decodedModel {
				case .success(let model):
					return .success(model)
				case .failure(let decodeError):
					return .failure(.decoding(decodeError))
				}
			case .failure(let error):
				return .failure(.jsonParsing(error))
			}
		}
	}
	
	static func ArgoResponseSerializer
		<Model: Decodable where Model.DecodedType == Model>(_ keyPath: String) -> ResponseSerializer<[Model], Error> {
		return ResponseSerializer { request, response, data, error in
			
			if let error = error {
				return .failure(.underlying(error))
			}
			
			let JSONSerializer = Request.JSONResponseSerializer()
			switch JSONSerializer.serializeResponse(request, response, data, error) {
			case .success(let jsonObject):
				guard let modelObject = jsonObject.value(forKeyPath: keyPath) else {
					return .failure(.unknown)
				}
				
				let decodedModels: Decoded<[Model]> = decode(modelObject) as Decoded<[Model]>
				switch decodedModels {
				case .success(let model):
					return .success(model)
				case .failure(let decodeError):
					return .failure(.decoding(decodeError))
				}
			case .failure(let error):
				return .failure(.jsonParsing(error))
			}
		}
	}
}
