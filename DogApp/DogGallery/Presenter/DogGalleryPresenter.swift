//
//  DogGalleryPresenter.swift
//  DogApp
//
//  Created by Wilfred Anorma on 29/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import Foundation
protocol DogGalleryPresenterOutput {
    var selectedBreed:Box<String?> { get }
    var breedOptions:Box<[String]> { get }
    var dogPhotoRecord:Box<[PhotoRecord]> { get }
}
protocol DogGalleryPresentable {
    func presentFetchedDogBreeds(_ breeds:[String:[String]?])
    func presentFetchedDogImages(_ links:[String])
}
final class DogGalleryPresenter:DogGalleryPresenterOutput,DogGalleryPresentable {
    
    private (set) var selectedBreed:Box<String?> = Box(nil)
    private (set) var breedOptions:Box<[String]> = Box([])
    private (set) var dogPhotoRecord:Box<[PhotoRecord]> = Box([])
    
    weak var view:DogGalleryDisplayable?
    
    func presentFetchedDogBreeds(_ breeds:[String:[String]?])
    {
        guard breeds.count == 1 else {
            selectedBreed.value = nil
            breedOptions.value = breeds.map({ (key,_) -> String in
                return key.capitalized
            })
            updateView(breedOptions.value, withSelectedItem: selectedBreed.value)
            return
        }
        for (key,values) in breeds {
            selectedBreed.value = key.capitalized
            breedOptions.value = values?.map({ (breed) -> String in
                return breed.capitalized
            }) ?? []
        }
        updateView(breedOptions.value, withSelectedItem: selectedBreed.value)
    }
    func presentFetchedDogImages(_ links:[String])
    {
        dogPhotoRecord.value = links.map({ (link) -> PhotoRecord in
            guard let url = URL(string: link) else {
                return PhotoRecord(name: "Invalid Link", url: URL(string: "https://i.ebayimg.com/images/g/MWMAAOSwxCxT-x0s/s-l300.jpg")!)
            }
            let name = link
            return PhotoRecord(name: name, url: url)
        })
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.updatePhotoRecords(weakSelf.dogPhotoRecord.value)
        }
    }
    
    //MARK: Helper Methods
    func updateView(_ options:[String], withSelectedItem item:String?)
    {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view?.updateTitle(item)
            weakSelf.view?.updateOptions(options, withSelectedItem: item)
        }
    }
}
