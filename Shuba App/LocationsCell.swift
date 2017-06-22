//
//  LocationsCell.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 18/06/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit

class LocationsCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0/255, green: 107/255, blue: 221/255, alpha: 1.0) : UIColor.white
            
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        
            iconImageView.tintColor = isHighlighted ? UIColor.white : UIColor.black
            
        }
    }
//    
//    var stops: Stop? {
//        didSet {
//            nameLabel.text = stops?.stopName
//        }
//    }
//    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Locations"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nearbystops")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        addSubview(nameLabel)
        addSubview(iconImageView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]-8-[v1]|", views: iconImageView, nameLabel)
        
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        
        addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
