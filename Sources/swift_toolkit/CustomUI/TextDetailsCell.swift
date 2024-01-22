//
//  TextDetailsCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 06.04.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

public class TextDetailsCell : UITableViewCell {
    public var title: RWLabel!
    public var subtitle: RWLabel!
    public var checkmark: RWLabel!
    
    public var flipped: Bool? {
        didSet {
           createConstraints()
        }
    }
    
    public var isChecked: Bool? {
        didSet {
           createConstraints()
        }
    }
    
    var con = [NSLayoutConstraint]()

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLabel(fontSize: CGFloat) -> RWLabel {
        let label = RWLabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 310
        
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }
    
    func createConstraints() {
        var _con: [NSLayoutConstraint]

        NSLayoutConstraint.deactivate(con)
        
        checkmark.isHidden = true
        checkmark.textColor = Theme.textColor

        if flipped ?? false {
            _con = [
                subtitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
                subtitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
                subtitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
                subtitle.bottomAnchor.constraint(equalTo: title.topAnchor),
                
                title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
                title.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
                title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0),
            ]
            
        } else {
            _con = [
                title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
                title.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
                title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
                title.bottomAnchor.constraint(equalTo: subtitle.topAnchor),
                
                subtitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
                subtitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
                subtitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0),
            ]
            
            if isChecked ?? false {
                checkmark.isHidden = false
                
                _con.append(contentsOf: [
                    checkmark.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0),
                    checkmark.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0),
                    checkmark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
                    ] )
            }
        }
        
        con = _con.map() { $0.priority = UILayoutPriority(999); return $0 }
       
        NSLayoutConstraint.activate(con)
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title = createLabel(fontSize: 20)
        subtitle = createLabel(fontSize: 17)
        checkmark = createLabel(fontSize: 25)
        
        checkmark.text = "\u{2714}\u{FE0E}"
        
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(checkmark)

        createConstraints()
    }
    
}

extension TextDetailsCell: ReusableView {}
