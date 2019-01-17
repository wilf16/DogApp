//
//  DogImagesViewController.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import UIKit

class DogImagesViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var dataSource:[[PhotoRecord]] = []
    let imageCache = NSCache<AnyObject,AnyObject>()
    let pendingOperations = PendingOperations()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        self.collectionView.isPagingEnabled = true
        self.collectionView.prefetchDataSource = self
        self.collectionView!.register(DogImagesCell.self, forCellWithReuseIdentifier: DogImagesCellIdentifier)
    }
    func reloadImages(with photoRecords: [PhotoRecord]) {
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingOperations.downloadQueue.cancelAllOperations()
            self?.pendingOperations.downloadsInProgress.removeAll()
            let dataSource = photoRecords.chunked(into: 10)
            self?.collectionView.prefetchDataSource = nil
            self?.dataSource = dataSource
            self?.collectionView.reloadData()
            self?.collectionView.prefetchDataSource = self
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DogImagesCellIdentifier, for: indexPath) as! DogImagesCell
        let photos = self.dataSource[indexPath.row]
        cell.dataSource = photos

        let parentCellRow = indexPath.row
        for i in 0..<photos.count {
            let photoRecord = photos[i]
            if let image = photoRecord.image {
               cell.reloadCellImage(image, at: IndexPath(row: i, section: 0))
            } else if let image = self.imageCache.object(forKey: photoRecord.url as AnyObject) as? UIImage {
                cell.reloadCellImage(image, at: IndexPath(row: i, section: 0))
            }else {
                cell.reloadCellImage(nil, at: IndexPath(row: i, section: 0))
               self.startOperations(for: photoRecord, at: IndexPath(row: i, section: parentCellRow))
            }
        }
        
        return cell
    }
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.width - 20, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    //MARK: - Helper Methods
    func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        default:
            NSLog("do nothing")
        }
    }
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        //1
        guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        
        //2
        let downloader = ImageDownloader(photoRecord)
        
        //3
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            
            DispatchQueue.main.async {
                guard let imageDownloader = self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath) as? ImageDownloader,
                let image = imageDownloader.photoRecord.image else { return }
                self.imageCache.setObject(image, forKey: imageDownloader.photoRecord.url as AnyObject)
                let parentCellIndexPath = IndexPath(row: indexPath.section, section: 0)
                if let cell = self.collectionView.cellForItem(at: parentCellIndexPath) as? DogImagesCell {
                    cell.reloadCellImage(image, at: IndexPath(row: indexPath.row, section: 0))
                }
            }
        }
        
        //4
        pendingOperations.downloadsInProgress[indexPath] = downloader
        
        //5
        pendingOperations.downloadQueue.addOperation(downloader)
    }
}
extension DogImagesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let photos = self.dataSource[indexPath.row]
            let parentCellRow = indexPath.row
            for i in 0..<photos.count {
                let photoRecord = photos[i]
                guard photoRecord.image == nil, (self.imageCache.object(forKey: photoRecord.url as AnyObject) as? UIImage) == nil else {
                    continue
                }
                self.startOperations(for: photoRecord, at: IndexPath(row: i, section: parentCellRow))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let photos = self.dataSource[indexPath.row]
            let parentCellRow = indexPath.row
            for i in 0..<photos.count {
                let childIndexPath = IndexPath(row: i, section: parentCellRow)
                if let imageDownloader = pendingOperations.downloadsInProgress[childIndexPath] {
                    imageDownloader.cancel()
                    self.pendingOperations.downloadsInProgress.removeValue(forKey: childIndexPath)
                }
            }
            
        }
    }
}
