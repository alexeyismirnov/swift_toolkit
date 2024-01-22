//
//  ImageViewCell.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 8/13/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//


import UIKit

public class ImageViewCell: UICollectionViewCell {
    public var icon: UIImageView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        icon = UIImageView()

        contentView.addSubview(icon)
        contentView.fullScreen(view: icon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageViewCell: ReusableView {}

