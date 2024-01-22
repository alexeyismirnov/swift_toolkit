//
//  DayViewCell.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 8/2/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public class SelectedDayViewCell: DayViewCell {
    override func configureCell(date: Date?, fontSize: CGFloat, textColor: UIColor) {
        super.configureCell(date: date, fontSize: fontSize, textColor: textColor)
       
        title.layer.cornerRadius = fontSize
        title.backgroundColor = .red
        title.textColor = .white
        
        title.removeConstraints()
        
        title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        title.widthAnchor.constraint(equalToConstant: fontSize + 15.0).isActive = true
        title.heightAnchor.constraint(equalToConstant: fontSize + 15.0).isActive = true
    }

}

public class DayViewCell: LabelViewCell {
    public var currentDate : Date?

    func configureCell(date: Date?, fontSize: CGFloat, textColor: UIColor) {
        contentView.backgroundColor =  UIColor.clear
        title.backgroundColor =  UIColor.clear
        
        currentDate = date
        guard let date = date else { title.text = ""; return }
        
        title.text = String(format: "%d", date.day)
        let fasting = ChurchFasting.forDate(date)

        if !Cal.getGreatFeast(date).isEmpty {
            title.font = UIFont.boldSystemFont(ofSize: fontSize)
            title.textColor = .red

        } else {
            title.font = UIFont.systemFont(ofSize: fontSize)
            title.textColor = (fasting.type == .noFast || fasting.type == .noFastMonastic)
                ? textColor
                : .black
        }
        
        contentView.backgroundColor = fasting.color
        
    }
}
