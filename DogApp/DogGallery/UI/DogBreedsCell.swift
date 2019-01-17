//
//  DogBreedsCell.swift
//  DogApp
//
//  Created by Wilfred Anorma on 25/11/2018.
//  Copyright © 2018 Wilfred Anorma. All rights reserved.
//

import UIKit

public let DogBreedsCellIdentifier = "DogBreedsCell"

class DogBreedsCell: UICollectionViewCell {
    private let selectedColor:UIColor = UIColor.purple
    private let unselectedColor:UIColor = UIColor.blue
    private (set) var titleLabel:UILabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = selectedColor.cgColor
                titleLabel.textColor = selectedColor
                backgroundColor = selectedColor.withAlphaComponent(0.2)
            } else {
                layer.borderColor = unselectedColor.cgColor
                titleLabel.textColor = unselectedColor
                backgroundColor = unselectedColor.withAlphaComponent(0.2)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()
    {
        self.backgroundColor = unselectedColor.withAlphaComponent(0.2)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = unselectedColor.cgColor
        
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        titleLabel.textColor = unselectedColor
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
        }
    }
    
    func configure(title:String, selected:Bool)
    {
        titleLabel.text = title
        isSelected = selected
    }
}
