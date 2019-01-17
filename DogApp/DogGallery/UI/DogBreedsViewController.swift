//
//  DogBreedsViewController.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import UIKit

protocol DogBreedsViewControllerDelegate: class {
    func didSelectBreed(_ breed:String)
}
class DogBreedsViewController: UICollectionViewController {
    
    weak var delegate:DogBreedsViewControllerDelegate?
    private (set) var dataSource:[String] = []
    private (set) var selectedBreed:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = false
        self.collectionView!.register(DogBreedsCell.self, forCellWithReuseIdentifier: DogBreedsCellIdentifier)
    }
    
    func updateBreeds(_ breeds:[String], withSelectedBreed breed:String?)
    {
        DispatchQueue.main.async { [unowned self] in
            self.dataSource = breeds
            self.selectedBreed = breed
            self.collectionView.reloadData()
        }
    }
}
// MARK: - UICollectionViewDelegate
extension DogBreedsViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let breed = dataSource[indexPath.row]
        self.selectedBreed = breed
        delegate?.didSelectBreed(breed)
        collectionView.reloadData()
    }
}
// MARK: - UICollectionViewDataSource
extension DogBreedsViewController {
   
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DogBreedsCellIdentifier, for: indexPath) as! DogBreedsCell
        let breed = dataSource[indexPath.row]
        let selected:Bool = self.selectedBreed == nil ? false : self.selectedBreed! == breed
        cell.configure(title: breed.capitalized, selected: selected)
        return cell
    }
}
//MARK: - UICollectionViewDelegateFlowLayout
extension DogBreedsViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let font = UIFont(name: "HelveticaNeue-Medium", size: 16.0) else { return CGSize.zero }
        let text = dataSource[indexPath.row]
        let width = Utilities.getTextLabelWidth(with: text, using: font)
        return CGSize.init(width: width + 20, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
