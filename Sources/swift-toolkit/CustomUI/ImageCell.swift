//
//  ImageCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 30.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

public class ImageCell : UITableViewCell {
    public var title: RWLabel!
    public var icon: UIImageView!
    
    var con : [NSLayoutConstraint]!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title = RWLabel()
        title.numberOfLines = 0
        title.preferredMaxLayoutWidth = 310
        
        title.font = UIFont.systemFont(ofSize: 17.0)
        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        contentView.addSubview(icon)
        
        con = [
            icon.widthAnchor.constraint(equalToConstant: 35.0),
            icon.heightAnchor.constraint(equalToConstant: 35.0),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            icon.rightAnchor.constraint(equalTo: title.leftAnchor, constant: -10.0),
            icon.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),

            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            title.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
            title.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(con.map() { $0.priority = UILayoutPriority(999); return $0 })
    }
    
}

extension ImageCell: ReusableView {}
