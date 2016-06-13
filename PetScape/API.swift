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
	
	static let baseKeyPath = "petfinder"
	
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
