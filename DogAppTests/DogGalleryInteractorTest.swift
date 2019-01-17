//
//  DogGalleryInteractorTest.swift
//  DogAppTests
//
//  Created by Wilfred Anorma on 30/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import XCTest
@testable import DogApp
class DogGalleryInteractorTest: XCTestCase {

    var mockedPresenter:MockedPresenter!
    var mockedNetworkManager:MockedNetworkManager!
    var sut:DogGalleryInteractor!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockedPresenter = MockedPresenter()
        mockedNetworkManager = MockedNetworkManager()
        sut = DogGalleryInteractor(presenter: mockedPresenter, networkManager: mockedNetworkManager)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockedNetworkManager = nil
        mockedPresenter = nil
    }
    //MARK: - FetchDogGalleryData
    func test_fetchDogGalleryData_successful()
    {
        //Given
        mockedNetworkManager.dogList = ["frise":["bichon"],
                                        "germanshepherd":[],
                                        "greyhound":["italian"],
                                        "groenendael":[],
                                        "hound":["afghan","basset","blood","english","ibizan","walker"]]
        mockedNetworkManager.randomDogImages = ["https://images.dog.ceo/breeds/germanshepherd/n02106662_2631.jpg",
                                                "https://images.dog.ceo/breeds/keeshond/n02112350_7335.jpg",
                                                "https://images.dog.ceo/breeds/samoyed/n02111889_373.jpg",
                                                "https://images.dog.ceo/breeds/beagle/n02088364_16508.jpg",
                                                "https://images.dog.ceo/breeds/stbernard/n02109525_17025.jpg"]
        var expectedErrors:[Error]?
        //When
        let promise = expectation(description: "Fetch Dog Gallery")
        sut.fetchDogGalleryData { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!.count, mockedNetworkManager.dogList.count)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value.count, mockedNetworkManager.randomDogImages.count)
    }
    func test_fetchDogGalleryData_withDogListInvalidURLError()
    {
        //Given
        let invalidURLString = "https://dog.ceo/api/breeds/list"
        mockedNetworkManager.dogListError = DogAPIError.invalidURL(invalidURLString)
        var expectedErrors:[Error]? = nil

        //When
        let promise = expectation(description: "Invalid URL in getting dog breed list")
        sut.fetchDogGalleryData { (errors) in
            expectedErrors = errors
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertEqual(expectedErrors!.count, 1)
        switch (expectedErrors![0] as! DogAPIError) {
        case .invalidURL(let urlString):
            XCTAssertEqual(urlString, invalidURLString)
        }
    }
    func test_fetchDogGalleryData_withRandomDogImagesInvalidURLError()
    {
        //Given
        let invalidURLString = "https://dog.ceo/api/breeds/image/random"
        mockedNetworkManager.randomDogImagesError = DogAPIError.invalidURL(invalidURLString)
        var expectedErrors:[Error]? = nil
        
        //When
        let promise = expectation(description: "Invalid URL in getting random dog images")
        sut.fetchDogGalleryData { (errors) in
            expectedErrors = errors
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertEqual(expectedErrors!.count, 1)
        switch (expectedErrors![0] as! DogAPIError) {
        case .invalidURL(let urlString):
            XCTAssertEqual(urlString, invalidURLString)
        }
    }
    func test_fetchDogGalleryData_withDogListNetworkAPIError()
    {
        //Given
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.dogListError = NetworkAPIError.failed(error)
        var expectedErrors:[Error]? = nil
        
        //When
        let promise = expectation(description: "Network API getting dog breed list")
        sut.fetchDogGalleryData { (errors) in
            expectedErrors = errors
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertEqual(expectedErrors!.count, 1)
    }
    func test_fetchDogGalleryData_withRandomDogImagesNetworkAPIError()
    {
        //Given
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.randomDogImagesError = NetworkAPIError.failed(error)
        var expectedErrors:[Error]? = nil
        
        //When
        let promise = expectation(description: "Network API getting random dog images")
        sut.fetchDogGalleryData { (errors) in
            expectedErrors = errors
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertEqual(expectedErrors!.count, 1)
    }
    func test_fetchDogGalleryData_withDogList_and_RandomDogImagesNetworkAPIError()
    {
        //Given
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.dogListError = NetworkAPIError.failed(error)
        mockedNetworkManager.randomDogImagesError = NetworkAPIError.failed(error)
        var expectedErrors:[Error]? = nil
        
        //When
        let promise = expectation(description: "Network API getting dog breed list")
        sut.fetchDogGalleryData { (errors) in
            expectedErrors = errors
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertEqual(expectedErrors!.count, 2)
    }
    //MARK: - FetchedDogGalleryDataForBreed
    func test_fetchDodGalleryDataForBreed_withNoOptionSuccessful()
    {
        //Given
        let breed = "hound"
        let expectedBreedDictionary:[String:[String]?] = [breed:[]]
        let expectedDogImages = ["image_link_url"]
        mockedNetworkManager.dogList = expectedBreedDictionary
        mockedNetworkManager.dogImages = expectedDogImages
        var expectedErrors:[Error]?
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        
        //When
        let promise = expectation(description: "Single option of fetching dog gallery with breed")
        sut.fetchDogGalleryData(for: breed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedBreedDictionary)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_fetchDodGalleryDataForBreed_withNilOptionSuccessful()
    {
        //Given
        let breed = "hound"
        let expectedBreedDictionary:[String:[String]?] = [breed:nil]
        let expectedDogImages = ["image_link_url"]
        mockedNetworkManager.dogList = expectedBreedDictionary
        mockedNetworkManager.dogImages = expectedDogImages
        var expectedErrors:[Error]?
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        
        //When
        let promise = expectation(description: "Single option of fetching dog gallery with breed")
        sut.fetchDogGalleryData(for: breed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedBreedDictionary)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_fetchDodGalleryDataForBreed_withSingleOptionSuccessful()
    {
        //Given
        let breed = "hound"
        let expectedBreedDictionary = [breed:["afghan","basset","blood","english","ibizan","walker"]]
        let expectedDogImages = ["image_link_url"]
        mockedNetworkManager.dogList = expectedBreedDictionary
        mockedNetworkManager.dogImages = expectedDogImages
        var expectedErrors:[Error]?
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        
        //When
        let promise = expectation(description: "Single option of fetching dog gallery with breed")
        sut.fetchDogGalleryData(for: breed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedBreedDictionary)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_fetchDodGalleryDataForBreed_withMultipleOptionsOptionSuccessful()
    {
        //Given
        let breed = "hound"
        let subBreeds = ["afghan","basset","blood","english","ibizan","walker"]
        let expectedDogImages = ["image_link_url"]
        let expectedSubBreed:[String:[String]?] = [breed:subBreeds]
        var breedDictionary:[String:[String]?] = ["frise":["bichon"]]
        breedDictionary[breed] = subBreeds
        
        mockedNetworkManager.dogList = breedDictionary
        mockedNetworkManager.dogImages = expectedDogImages
        var expectedErrors:[Error]?
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        
        //When
        let promise = expectation(description: "Multiple options of fetching dog gallery with breed")
        sut.fetchDogGalleryData(for: breed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_fetchDodGalleryDataForBreed_withASubBreedSelectedSuccessful()
    {
        //Given
        let breed = "hound"
        let subBreed = "english"
        let expectedDogImages = ["image_link_url"]
        let expectedBreedDictionary = ["hound":["afghan","basset","blood","english","ibizan","walker"]]
        mockedNetworkManager.dogList = expectedBreedDictionary
        mockedNetworkManager.dogImages = expectedDogImages
        var expectedErrors:[Error]?
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: breed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        
        //When
        let promise = expectation(description: "Multiple options of fetching dog gallery with sub-breed")
        sut.fetchDogGalleryData(for: subBreed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
         XCTAssertNil(expectedErrors)
        XCTAssertNotNil(sut.selectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogSubBreed!, "hound-\(subBreed)")
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedBreedDictionary)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_fetchDodGalleryDataForBreed_withInvalidURLError()
    {
        //Given
        let breed = "houndsss"
        let invalidURLString = "https://dog.ceo/api/breed/\(breed)/images"
        mockedNetworkManager.dogImagesError = DogAPIError.invalidURL(invalidURLString)
        mockedNetworkManager.dogList = [breed:["afghan","basset","blood","english","ibizan","walker"]]
        var expectedErrors:[Error]?
        sut.fetchDogGalleryData()
        //When
        let promise = expectation(description: "Invalid URL when fetching dog gallery with breed")
        sut.fetchDogGalleryData(for: breed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNotNil(expectedErrors)
        switch (expectedErrors![0] as! DogAPIError) {
        case .invalidURL(let urlString):
            XCTAssertEqual(urlString, invalidURLString)
        }
    }
    func test_fetchDodGalleryDataForBreed_withNetworkAPIError()
    {
        //Given
        let breed = "hound"
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.dogImagesError = NetworkAPIError.failed(error)
        mockedNetworkManager.dogList = [breed:["afghan","basset","blood","english","ibizan","walker"]]
        var expectedErrors:[Error]?
        sut.fetchDogGalleryData()
        //When
        let promise = expectation(description: "Invalid URL when fetching dog gallery with breed")
        sut.fetchDogGalleryData(for: breed) { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNotNil(expectedErrors)
    }
    //MARK: - UndoSelectedDogBreed
    func test_undoSlectedDogBreed_withSelectedBreedSuccessful()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let selectedBreed = "hound"
        let expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[],
                                 selectedBreed:["afghan","basset","blood","english","ibizan","walker"]]
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedError:Error?
       
        //When
        let promise = expectation(description: "Undo dog breed selection")
        sut.undoSelectedDogBreed { (error) in
            expectedError = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNil(expectedError)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_undoSlectedDogBreed_withSelectedSubBreedSuccessful()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let selectedBreed = "hound"
        let selectedSubBreed = "basset"
        let subBreeds = ["afghan",selectedBreed,"blood","english","ibizan","walker"]
        
        var expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[]]
        expectedDogBreed[selectedBreed] = subBreeds
        let expectedDogSubBreed = [selectedBreed:subBreeds]
        
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        mockedNetworkManager.dogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise3 = expectation(description: "Setup dog list and images with selected sub-breed")
        sut.fetchDogGalleryData(for: selectedSubBreed) { (error) in setupPromise3.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedError:Error?
        //When
        let promise = expectation(description: "Undo dog breed selection")
        sut.undoSelectedDogBreed { (error) in
            expectedError = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNil(expectedError)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_undoSlectedDogBreed_withSelectedBreedInvalidURLError()
    {
        //Given
        let selectedBreed = "hound"
        let expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[],
                                 selectedBreed:["afghan","basset","blood","english","ibizan","walker"]]
        mockedNetworkManager.dogList = expectedDogBreed
        let invalidURLString = "https://dog.ceo/api/breeds/image/random"
        mockedNetworkManager.randomDogImagesError = DogAPIError.invalidURL(invalidURLString)
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedError:Error?
        
        //When
        let promise = expectation(description: "Undo dog breed selection")
        sut.undoSelectedDogBreed { (error) in
            expectedError = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedError)
        switch (expectedError as! DogAPIError) {
        case .invalidURL(let urlString):
            XCTAssertEqual(urlString, invalidURLString)
        }
    }
    func test_undoSlectedDogBreed_withSelectedBreedNetworkAPIError()
    {
        //Given
        let selectedBreed = "hound"
        let expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[],
                                 selectedBreed:["afghan","basset","blood","english","ibizan","walker"]]
        mockedNetworkManager.dogList = expectedDogBreed
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.randomDogImagesError = NetworkAPIError.failed(error)
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedError:Error?
        
        //When
        let promise = expectation(description: "Undo dog breed selection")
        sut.undoSelectedDogBreed { (error) in
            expectedError = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        //Then
        XCTAssertNotNil(expectedError)
    }
    //MARK: - RefreshSelectedDogBreed
    func test_refreshSelectedDogGallery_withoutSelectedBreed()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[],
                                 "hound":["afghan","basset","blood","english","ibizan","walker"]]
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedErrors:[Error]?
        //When
        let promise = expectation(description: "Refresh dog breed selection")
        sut.refreshSelectedDogBreed { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_refreshSelectedDogGallery_withSelectedBreed()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let selectedBreed = "hound"
        let subBreeds = ["afghan","basset","blood","english","ibizan","walker"]
        var expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[]]
        expectedDogBreed[selectedBreed] = subBreeds
        let expectedDogSubBreed = [selectedBreed:subBreeds]
        
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        mockedNetworkManager.dogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedErrors:[Error]?
        //When
        let promise = expectation(description: "Refresh dog breed selection")
        sut.refreshSelectedDogBreed { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_refreshSelectedDogGallery_withSelectedBreedError()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let selectedBreed = "hound"
        let subBreeds = ["afghan","basset","blood","english","ibizan","walker"]
        var expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[]]
        expectedDogBreed[selectedBreed] = subBreeds
        let expectedDogSubBreed = [selectedBreed:subBreeds]
        
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        mockedNetworkManager.dogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.dogImagesError = NetworkAPIError.failed(error)
        var expectedErrors:[Error]?
        //When
        let promise = expectation(description: "Refresh dog breed selection")
        sut.refreshSelectedDogBreed { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertNil(sut.selectedDogSubBreed)
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_refreshSelectedDogGallery_withSelectedSubBreedError()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let selectedBreed = "hound"
        let selectedSubBreed = "basset"
        let subBreeds = ["afghan",selectedBreed,"blood","english","ibizan","walker"]
        
        var expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[]]
        expectedDogBreed[selectedBreed] = subBreeds
        let expectedDogSubBreed = [selectedBreed:subBreeds]
        
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        mockedNetworkManager.dogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise3 = expectation(description: "Setup dog list and images with selected sub-breed")
        sut.fetchDogGalleryData(for: selectedSubBreed) { (error) in setupPromise3.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let error = NSError.init(domain: "TestError", code: 0, userInfo: nil)
        mockedNetworkManager.dogImagesError = NetworkAPIError.failed(error)
        var expectedErrors:[Error]?
        //When
        let promise = expectation(description: "Undo dog breed selection")
        sut.refreshSelectedDogBreed { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNotNil(expectedErrors)
        XCTAssertNotNil(sut.selectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogSubBreed!, "\(selectedBreed)-\(selectedSubBreed)")
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    func test_refreshSelectedDogGallery_withSelectedSubBreed()
    {
        //Given
        let expectedDogImages = ["image_link_url"]
        let selectedBreed = "hound"
        let selectedSubBreed = "basset"
        let subBreeds = ["afghan",selectedBreed,"blood","english","ibizan","walker"]
        
        var expectedDogBreed =  ["frise":["bichon"],
                                 "germanshepherd":[],
                                 "greyhound":["italian"],
                                 "groenendael":[]]
        expectedDogBreed[selectedBreed] = subBreeds
        let expectedDogSubBreed = [selectedBreed:subBreeds]
        
        mockedNetworkManager.dogList = expectedDogBreed
        mockedNetworkManager.randomDogImages = expectedDogImages
        mockedNetworkManager.dogImages = expectedDogImages
        let setupPromise = expectation(description: "Setup dog list and images with given.")
        sut.fetchDogGalleryData { (_) in setupPromise.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise2 = expectation(description: "Setup dog list and images with selected breed.")
        sut.fetchDogGalleryData(for: selectedBreed) { (_) in setupPromise2.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        let setupPromise3 = expectation(description: "Setup dog list and images with selected sub-breed")
        sut.fetchDogGalleryData(for: selectedSubBreed) { (error) in setupPromise3.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        var expectedErrors:[Error]?
        //When
        let promise = expectation(description: "Undo dog breed selection")
        sut.refreshSelectedDogBreed { (error) in
            expectedErrors = error
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        //Then
        XCTAssertNil(expectedErrors)
        XCTAssertNotNil(sut.selectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogSubBreed!, "\(selectedBreed)-\(selectedSubBreed)")
        XCTAssertNotNil(sut.selectedDogBreed.value)
        XCTAssertEqual(sut.selectedDogBreed.value!, expectedDogSubBreed)
        XCTAssertEqual(sut.selectedDogBreedImageLinks.value, expectedDogImages)
    }
    //MARK: - Helper Methods
    class MockedNetworkManager:DogGalleryNetworkLayerProtocol {
        var dogList:[String : [String]?] = [:]
        var dogListError:Error? = nil

        var randomDogImages:[String] = []
        var randomDogImagesError:Error? = nil

        var dogImages:[String] = []
        var dogImagesError:Error? = nil

        func fetchDogList(withBreed breed: String?, completion: @escaping ([String : [String]?], Error?) -> Void) throws {
            if let error = dogListError as? DogAPIError {
                throw error
            }
            completion(dogList,dogListError)
        }
        
        func fetchRandomDogImages(max: Int, completion: @escaping ([String], Error?) -> Void) throws {
            if let error = randomDogImagesError as? DogAPIError {
                throw error
            }
            completion(randomDogImages,randomDogImagesError)
        }
        
        func fetchDogImages(for breed: String, completion: @escaping ([String], Error?) -> Void) throws {
            if let error = dogImagesError as? DogAPIError {
                throw error
            }
            completion(dogImages,dogImagesError)
        }
    }
    class MockedPresenter:DogGalleryPresentable {
        func presentFetchedDogBreeds(_ breeds: [String : [String]?]) {
            
        }
        
        func presentFetchedDogImages(_ links: [String]) {
            
        }
    }
}
