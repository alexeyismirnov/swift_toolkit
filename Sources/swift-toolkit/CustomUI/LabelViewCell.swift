//
//  LabelViewCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/24/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public class LabelViewCell: UICollectionViewCell {
    public var title: UILabel!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        title = UILabel()

        title.numberOfLines = 1
        title.font = UIFont.systemFont(ofSize: Theme.defaultFontSize)
        title.textColor = Theme.textColor
        title.adjustsFontSizeToFitWidth = false
        title.clipsToBounds = true
        title.textAlignment = .center
        title.baselineAdjustment = .alignCenters
        
        contentView.addSubview(title)
        contentView.fullScreen(view: title)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LabelViewCell: ReusableView {}
