//
//  DogImagesCell.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import UIKit

public let DogImagesCellIdentifier = "DogImagesCell"

class DogImagesCell: UICollectionViewCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var dataSource:[PhotoRecord] = []
    let imagesCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        imagesCollectionView.register(DogImageCell.self, forCellWithReuseIdentifier: DogImageCellIdentifier)
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCellImage(_ image:UIImage?, at indexPath:IndexPath)
    {
        self.dataSource[indexPath.row].image = image
        self.imagesCollectionView.reloadData()
    }
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DogImageCellIdentifier, for: indexPath) as! DogImageCell
        let photo = dataSource[indexPath.row]
        cell.imageView.image = photo.image
        if photo.image == nil {
            cell.loadingIndicator.startAnimating()
        } else {
            cell.loadingIndicator.stopAnimating()
        }
        return cell
    }
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let photo = dataSource[indexPath.row]
        let maxWidth = self.frame.width
        guard var imageSize = photo.image?.size else {
            return CGSize.init(width: maxWidth, height: maxWidth)
        }
        guard imageSize.width > maxWidth else {
            return imageSize
        }
        let percent = (maxWidth / imageSize.width)
        imageSize.width = imageSize.width * percent
        imageSize.height = imageSize.height * percent
        return imageSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
}
public let DogImageCellIdentifier = "DogImageCell"
class DogImageCell: UICollectionViewCell {
    var imageView:UIImageView = UIImageView()
    var loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 67/255, green: 145/255, blue: 249/255, alpha: 1)
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
        }
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(0)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
