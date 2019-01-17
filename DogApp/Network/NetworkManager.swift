//
//  NetworkManager.swift
//  DogApp
//
//  Created by Wilfred Anorma on 30/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import Foundation

enum NetworkAPIError : Error {
    case failed(Error)
    case failedToSerializeJSONResponse(Error)
    case invalidDataResponse(Error)
    case noData(Error)
}
class NetworkManager {
    func fetchDataArray(withURL url:URL, completion: @escaping ([String],Error?) -> Void)
    {
        let urlRequest = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion([],NetworkAPIError.failed(error))
                return
            }
            guard let data = data else {
                let error = NSError.init(domain: "NetworkAPIEror", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: ["url":url.absoluteString])
                completion([],NetworkAPIError.noData(error))
                return }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    let error = NSError.init(domain: "NetworkAPIEror", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: ["url":url.absoluteString])
                    completion([],NetworkAPIError.failedToSerializeJSONResponse(error))
                    return
                }
                if let status = json["status"] as? String, status == "error" {
                    let code = Int(json["error"] as? String ?? "0")!
                    let message = json["message"] as? String ?? "Invalid Status"
                    let error = NSError.init(domain: "NetworkAPIEror", code: code, userInfo: ["url":url.absoluteString, "message": message])
                    completion([],NetworkAPIError.failed(error))
                    return
                }
                //print("JSON: \(json)")
                guard let array = json["message"] as? [String] else {
                    let error = NSError.init(domain: "NetworkAPIEror", code: 0, userInfo: ["url":url.absoluteString])
                    completion([],NetworkAPIError.invalidDataResponse(error))
                    return
                }
                completion(array,nil)
            } catch let error {
                completion([],NetworkAPIError.failedToSerializeJSONResponse(error))
            }
        }
        task.resume()
    }
    func fetchDataDictionary(withURL url:URL, completion: @escaping ([String:[String]?],Error?) -> Void)
    {
        let urlRequest = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion([:],NetworkAPIError.failed(error))
                return
            }
            guard let data = data else {
                let error = NSError.init(domain: "NetworkAPIEror", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: ["url":url.absoluteString])
                completion([:],NetworkAPIError.noData(error))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                    let error = NSError.init(domain: "NetworkAPIEror", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: ["url":url.absoluteString])
                    completion([:],NetworkAPIError.failedToSerializeJSONResponse(error))
                    return
                }
                if let status = json["status"] as? String, status == "error" {
                    let code = Int(json["error"] as? String ?? "0")!
                    let message = json["message"] as? String ?? "Invalid Status"
                    let error = NSError.init(domain: "NetworkAPIEror", code: code, userInfo: ["url":url.absoluteString, "message": message])
                    completion([:],NetworkAPIError.failed(error))
                    return
                }
                guard let dict = json["message"] as? [String:[String]] else {
                    let error = NSError.init(domain: "NetworkAPIEror", code: 0, userInfo: ["url":url.absoluteString])
                    completion([:],NetworkAPIError.invalidDataResponse(error))
                    return
                }
                var simplifiedDict:[String:[String]?] = [:]
                dict.forEach({ (arg0) in
                    let (key, value) = arg0
                    if value.count == 0 {
                        simplifiedDict[key] = nil
                    } else if value.count == 1 {
                        simplifiedDict[key+"-"+value[0]] = nil
                    } else {
                        simplifiedDict[key] = value
                    }
                })
                completion(simplifiedDict,nil)
            } catch let error {
                completion([:],NetworkAPIError.failedToSerializeJSONResponse(error))
            }
        }
        task.resume()
    }
}
