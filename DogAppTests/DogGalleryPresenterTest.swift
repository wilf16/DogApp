//
//  DogGalleryPresenterTest.swift
//  DogAppTests
//
//  Created by Wilfred Anorma on 1/12/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import XCTest
@testable import DogApp

class DogGalleryPresenterTest: XCTestCase {

    var sut:DogGalleryPresenter!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = DogGalleryPresenter()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func test_presentFetchedDogBreeds_withSingleOptionWithSubBreeds()
    {
        //Given
        let breeds:[String:[String]?] = ["hound":["afghan","basset","blood","english","ibizan","walker"]]
        //When
        sut.presentFetchedDogBreeds(breeds)
        //Test
        XCTAssertNotNil(sut.selectedBreed.value)
        XCTAssertTrue(sut.breedOptions.value.count > 0)
    }
    func test_presentFetchedDogBreeds_withSingleOptionWithoutSubBreeds()
    {
        //Given
        let breeds:[String:[String]?] = ["hound":nil]
        //When
        sut.presentFetchedDogBreeds(breeds)
        //Test
        XCTAssertNotNil(sut.selectedBreed.value)
        XCTAssertTrue(sut.breedOptions.value.isEmpty)
        
    }
    func test_presentFetchedDogBreeds_withMultipleOption()
    {
        //Given
        let breeds:[String:[String]?] = ["frise":["bichon"],
                                         "germanshepherd":[],
                                         "greyhound":["italian"],
                                         "groenendael":[],
                                         "hound":["afghan","basset","blood","english","ibizan","walker"]]
        //When
        sut.presentFetchedDogBreeds(breeds)
        //Test
        XCTAssertNil(sut.selectedBreed.value)
        XCTAssertTrue(sut.breedOptions.value.count > 0)
    }
    func test_presentFetchedDogImages()
    {
        //Given
        let links =  ["https://images.dog.ceo/breeds/germanshepherd/n02106662_2631.jpg",
                      "https://images.dog.ceo/breeds/keeshond/n02112350_7335.jpg",
                      "https://images.dog.ceo/breeds/samoyed/n02111889_373.jpg",
                      "https://images.dog.ceo/breeds/beagle/n02088364_16508.jpg",
                      "https://images.dog.ceo/breeds/stbernard/n02109525_17025.jpg",
                      "Invalid Link"]
        //When
        sut.presentFetchedDogImages(links)
        //Then
        XCTAssertEqual(sut.dogPhotoRecord.value.count, links.count)
        let hasInvalidURL = sut.dogPhotoRecord.value.contains(where: { (record) in
            return record.name == "Invalid Link"
        })
        XCTAssertTrue(hasInvalidURL)
    }
}
