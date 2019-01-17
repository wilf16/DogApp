//
//  DogGalleryViewController.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import UIKit
protocol DogGalleryDisplayable:  class {
    func updateTitle(_ title:String?)
    func updateOptions(_ options:[String], withSelectedItem item:String?)
    func updatePhotoRecords(_ photos:[PhotoRecord])
}
final class DogGalleryViewController : UIViewController, DogBreedsViewControllerDelegate, DogGalleryDisplayable {

    private var interactor:DogGalleryBusinessLogic?

    lazy var breedsCollectionViewController:DogBreedsViewController = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        let collectionViewController = DogBreedsViewController(collectionViewLayout: collectionViewFlowLayout)
        self.addChild(collectionViewController)
     
        return collectionViewController
    }()
    lazy var imagesCollectionViewController:DogImagesViewController = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        let collectionViewController = DogImagesViewController(collectionViewLayout: collectionViewFlowLayout)
        self.addChild(collectionViewController)
        
        return collectionViewController
    }()
    
    override var title: String? {
        didSet {
            self.navigationItem.leftBarButtonItem?.isEnabled = title != nil
        }
    }

    convenience init(interactor:DogGalleryBusinessLogic) {
        self.init()
        self.interactor = interactor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.undo, target: self, action: #selector(self.undoDogSelection))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(self.refreshDogList))

        breedsCollectionViewController.delegate = self
        let breedsCollectionView = breedsCollectionViewController.view!
        self.view.addSubview(breedsCollectionView)
        breedsCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(56)
        }
        
        let imagessCollectionView = imagesCollectionViewController.view!
        self.view.addSubview(imagessCollectionView)
        imagessCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(breedsCollectionView.snp.bottom)
            make.leading.trailing.bottom.equalTo(0)
        }
        self.interactor?.fetchDogGalleryData(for: nil, completion: nil)
    }
    //MARK: - INPUT ACTIONS
    @objc func undoDogSelection()
    {
        self.interactor?.undoSelectedDogBreed(completion: nil)
    }
    @objc func refreshDogList()
    {
        self.interactor?.refreshSelectedDogBreed(completion: nil)
    }
    //MARK: DogBreedsViewControllerDelegate
    func didSelectBreed(_ breed: String)
    {
        self.interactor?.fetchDogGalleryData(for: breed, completion: nil)
    }
    //MARK: - OUTPUT DogGalleryDisplayable
    func updateTitle(_ title: String?) {
        self.title = title
    }
    
    func updateOptions(_ options: [String], withSelectedItem item: String?) {
        self.breedsCollectionViewController.updateBreeds(options, withSelectedBreed: item)
    }
    
    func updatePhotoRecords(_ photos: [PhotoRecord]) {
        self.imagesCollectionViewController.reloadImages(with: photos)
    }
    
}


