//
//  TextCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

public class TextCell : UITableViewCell  {
    public var title: RWLabel!
    var con : [NSLayoutConstraint]!

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title = RWLabel()
        title.numberOfLines = 0
        title.preferredMaxLayoutWidth = 310
        title.font = UIFont.systemFont(ofSize: 17)
        title.adjustsFontSizeToFitWidth = false
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        
        con = [
            title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            title.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0)
        ]
        
        NSLayoutConstraint.activate(con.map() { $0.priority = UILayoutPriority(999); return $0 })
    }
}

extension TextCell: ReusableView {}
