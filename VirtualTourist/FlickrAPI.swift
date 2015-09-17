//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Axel Guilmin on 9/10/15.
//  Copyright (c) 2015 Axel Guilmin. All rights reserved.
//

import Foundation

import Foundation

class FlickrAPI {
	
	static let BASE_URL = "https://api.flickr.com/services/rest/"
	static let API_KEY = "3f13bf1c3b6f4d4250a84b92ebc30e9f"
	static let EXTRAS = "url_m"
	static let DATA_FORMAT = "json"
	static let NO_JSON_CALLBACK = "1"
	
	static func get(#method:String, param:[String:AnyObject]? = nil, success:(Int, [String : AnyObject]?) -> () = {_,_ in}, failure:() -> () = {}) -> NSURLSessionDataTask{
		return request("GET", method: method, param: param, success: success, failure: failure)
	}
	
	static func post(#method:String, param:[String:AnyObject]? = nil, success:(Int, [String : AnyObject]?) -> () = {_,_ in}, failure:() -> () = {}) -> NSURLSessionDataTask {
		return request("POST", method: method, param: param, success: success, failure: failure)
	}
	
	static func put(#method:String, param:[String:AnyObject]? = nil, success:(Int, [String : AnyObject]?) -> () = {_,_ in}, failure:() -> () = {}) -> NSURLSessionDataTask {
		return request("PUT", method: method, param: param, success: success, failure: failure)
	}
	
	static func delete(#method:String, param:[String:AnyObject]? = nil, success:(Int, [String : AnyObject]?) -> () = {_,_ in}, failure:() -> () = {}) -> NSURLSessionDataTask {
		return request("DELETE", method: method, param: param, success: success, failure: failure)
	}
	
	
	static func request(httpMethod:String, method:String, param:[String:AnyObject]?, success:(Int, [String : AnyObject]?) -> (), failure:() -> ()) -> NSURLSessionDataTask {
		
		var allParam:[String:AnyObject] = param == nil ? [String:AnyObject]() : param!
		allParam["method"] = method
		allParam["api_key"] = API_KEY
		allParam["extras"] = EXTRAS
		allParam["format"] = DATA_FORMAT
		allParam["nojsoncallback"] = NO_JSON_CALLBACK
		
		let urlString = FlickrAPI.BASE_URL + escapedParameters(allParam)
		
		let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
		request.HTTPMethod = httpMethod
		request.timeoutInterval = 2 //seconds
		
		// Send request
		let session = NSURLSession.sharedSession() // OK
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil { // Network error
				println("↓ \(error.description)")
				failure()
				return
			}
			
			let statusCode:Int = (response as! NSHTTPURLResponse).statusCode
			let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil) as? [String : AnyObject]
			println("↓ \(statusCode) \(response.URL!.description)")
			success(statusCode, json)
		}
		println("↑ \(httpMethod) \(urlString)")
		task.resume()
		return task
	}
	
	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	static func escapedParameters(parameters: [String : AnyObject]) -> String {
		var urlVars = [String]()
		for (key, value) in parameters {
			
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			
			/* Append it */
			urlVars += [key + "=" + "\(escapedValue!)"]
		}
		return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
	}



}