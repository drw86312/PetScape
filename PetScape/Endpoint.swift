//
//  Endpoint.swift
//  PetScape
//
//  Created by David Warner on 6/10/16.
//  Copyright © 2016 drw. All rights reserved.
//

import Alamofire
import Argo

struct Endpoint<T> {
	let method: Alamofire.Method
	let path: String
	let parameters: [String: AnyObject]
	let headers: [String: String]?
	let defaultParameters: [String: AnyObject] = [API.kAPIOutput : API.kAPIOutputDefaultValue,
	                                              API.kAPIFormat : API.kAPIFormatDefaultValue,
	                                              "key" : API.clientID]
}

extension Endpoint: URLRequestConvertible {
	var URLRequest: NSMutableURLRequest {
		let mutableRequest = NSMutableURLRequest(URL: API.baseURL.URLByAppendingPathComponent(path))
		mutableRequest.HTTPMethod = method.rawValue
		mutableRequest.allHTTPHeaderFields = headers
		let encoding = ParameterEncoding.URL
		return encoding.encode(mutableRequest, parameters: defaultParameters.withEntries(parameters)).0
	}
}
