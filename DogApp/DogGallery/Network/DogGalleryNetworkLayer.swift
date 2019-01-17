//
//  DogGalleryNetworkLayer.swift
//  DogApp
//
//  Created by Wilfred Anorma on 30/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import Foundation
enum DogAPIError:Error {
    case invalidURL(String)
}
protocol DogGalleryNetworkLayerProtocol {
    func fetchDogList(withBreed breed:String?, completion: @escaping ([String:[String]?],Error?) -> Void) throws
    func fetchRandomDogImages(max:Int, completion:@escaping ([String],Error?) -> Void) throws
    func fetchDogImages(for breed:String, completion: @escaping ([String],Error?)-> Void) throws
}
class DogGalleryNetworkLayer: NetworkManager, DogGalleryNetworkLayerProtocol {
    func fetchDogList(withBreed breed:String?, completion: @escaping ([String:[String]?],Error?) -> Void) throws {
        if let breed = breed {
            let stringURL = "https://dog.ceo/api/breed/\(breed)/all"
            guard let url = URL(string:stringURL) else { throw DogAPIError.invalidURL(stringURL) }
            fetchDataArray(withURL: url) { (breeds,error) in
                completion([breed:breeds],nil)
            }
        } else {
            let stringURL = "https://dog.ceo/api/breeds/list/all"
            guard let url = URL(string:stringURL) else { throw DogAPIError.invalidURL(stringURL) }
            fetchDataDictionary(withURL: url, completion: completion)
        }
    }
    func fetchRandomDogImages(max:Int = 50, completion:@escaping ([String],Error?) -> Void) throws
    {
        let urlString = "https://dog.ceo/api/breeds/image/random/\(max > 50 ? 50 : max)"
        guard let url = URL(string: urlString) else { throw DogAPIError.invalidURL(urlString) }
        fetchDataArray(withURL: url, completion: completion)
    }
    func fetchDogImages(for breed:String, completion: @escaping ([String],Error?)-> Void) throws
    {
        let urlString = "https://dog.ceo/api/breed/\(breed)/images"
        guard let url = URL(string: urlString) else { throw DogAPIError.invalidURL(urlString) }
        fetchDataArray(withURL: url, completion: completion)
    }
}
