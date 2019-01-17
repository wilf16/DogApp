//
//  DogGalleryInteractor.swift
//  DogApp
//
//  Created by Wilfred Anorma on 29/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import Foundation

protocol DogGalleryBusinessLogic {
    func fetchDogGalleryData(for breed:String?,completion:(([Error]?) -> Void)?)
    func undoSelectedDogBreed(completion:((Error?) -> Void)?)
    func refreshSelectedDogBreed(completion:(([Error]?) -> Void)?)
}
protocol DogGalleryInteractorOutput {
    var selectedDogBreed:Box<[String:[String]?]?> { get }
    var selectedDogBreedImageLinks:Box<[String]> { get }
}
final class DogGalleryInteractor:DogGalleryBusinessLogic, DogGalleryInteractorOutput{
    
    private var dogBreedList:[String:[String]?] = [:]
    private (set) var selectedDogBreed:Box<[String:[String]?]?> = Box(nil)
    private (set) var selectedDogBreedImageLinks:Box<[String]> = Box([])
    private (set) var selectedDogSubBreed:String? = nil
    private let maxRadomPhotoLinks = 50
    
    private let presenter:DogGalleryPresentable
    private var networkManager:DogGalleryNetworkLayerProtocol
    
    init(presenter:DogGalleryPresentable, networkManager:DogGalleryNetworkLayerProtocol) {
        self.presenter = presenter
        self.networkManager = networkManager
    }

    func fetchDogGalleryData(for breed: String? = nil, completion:(([Error]?) -> Void)? = nil) {
        if let breed = breed {
            fetchDogGalleryData(for: breed, completion: { (error) in
                if let error = error {
                    completion?([error])
                } else {
                    completion?(nil)
                }
            })
        } else {
            fetchDogGalleryData(completion: completion)
        }
    }
   
    func undoSelectedDogBreed(completion:((Error?) -> Void)? = nil)
    {
        if let _ = selectedDogSubBreed, let selectedDogBreed = self.selectedDogBreed.value, selectedDogBreed.count == 1 {
        let key = selectedDogBreed.keys.first!
            self.selectedDogBreed.value = nil
            fetchDogGalleryData(for: key, completion: completion)
        } else {
            presenter.presentFetchedDogBreeds(dogBreedList)
            selectedDogBreed.value = dogBreedList
            selectedDogSubBreed = nil
            do {
                try self.networkManager.fetchRandomDogImages(max: maxRadomPhotoLinks) { [unowned self] (links,error) in
                    if let error = error{
                        completion?(error)
                    } else {
                        self.presenter.presentFetchedDogImages(links)
                        self.selectedDogBreedImageLinks.value = links
                        completion?(nil)
                    }
                }
            } catch let error {
                completion?(error)
            }
        }
    }
    func refreshSelectedDogBreed(completion:(([Error]?) -> Void)? = nil)
    {
        if var subBreed = selectedDogSubBreed {
            if let indexOfDash = subBreed.index(of:"-") {
                subBreed = String(subBreed[subBreed.index(after: indexOfDash)...])
            }
            selectedDogSubBreed = nil
            
            self.fetchDogGalleryData(for: subBreed) { (error) in
                if let error = error {
                    completion?([error])
                } else {
                    completion?(nil)
                }
            }
        } else if let selectedDogBreed = self.selectedDogBreed.value, selectedDogBreed.count == 1 {
            let key = selectedDogBreed.keys.first!
            self.selectedDogBreed.value = nil
            self.fetchDogGalleryData(for: key) { (error) in
                if let error = error {
                    completion?([error])
                } else {
                    completion?(nil)
                }
            }
        } else {
            self.fetchDogGalleryData(completion: completion)
        }
    }
    
    //MARK: - Helper Methods
    private func fetchDogGalleryData(completion:(([Error]?) -> Void)? = nil)
    {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let fetchDataGroup = DispatchGroup()
            do {
                var storedError:[Error]? = []
                fetchDataGroup.enter()
                try self.networkManager.fetchDogList(withBreed: nil) { [unowned self] (breeds,error) in
                    if let error = error {
                        storedError?.append(error)
                    } else {
                        self.dogBreedList = breeds
                        self.selectedDogBreed.value = breeds
                        self.selectedDogSubBreed = nil
                        self.presenter.presentFetchedDogBreeds(breeds)
                    }
                    fetchDataGroup.leave()
                }
                fetchDataGroup.enter()
                try self.networkManager.fetchRandomDogImages(max: self.maxRadomPhotoLinks) { [unowned self] (links,error) in
                    if let error = error {
                        storedError?.append(error)
                    } else {
                        self.presenter.presentFetchedDogImages(links)
                        self.selectedDogBreedImageLinks.value = links
                    }
                    fetchDataGroup.leave()
                }
                fetchDataGroup.wait()
                storedError = storedError!.isEmpty == true ? nil : storedError
                completion?(storedError)
            } catch let error {
                fetchDataGroup.leave()
                completion?([error])
            }
        }
    }
    private func fetchDogGalleryData(for breed:String, completion:((Error?) -> Void)? = nil)
    {
        var key = breed.lowercased()
        if let selectedDogBreed = self.selectedDogBreed.value, selectedDogBreed.count == 1, selectedDogBreed.keys.first! != key {
            key = selectedDogBreed.keys.first! + "-" + key
            selectedDogSubBreed = key
        } else {
            selectedDogSubBreed = nil
            if let optionalDogBreedList = dogBreedList[key], let breeds = optionalDogBreedList {
                selectedDogBreed.value = [key:breeds]
            } else {
                selectedDogBreed.value = [key:nil]
            }
            self.presenter.presentFetchedDogBreeds(selectedDogBreed.value!)
        }
        do {
            try self.networkManager.fetchDogImages(for: key, completion: { [unowned self] (links,error) in
                if let error = error {
                    completion?(error)
                } else {
                    self.presenter.presentFetchedDogImages(links)
                    self.selectedDogBreedImageLinks.value = links
                    completion?(nil)
                }
            })
        } catch let error {
            completion?(error)
        }
        
    }
}
