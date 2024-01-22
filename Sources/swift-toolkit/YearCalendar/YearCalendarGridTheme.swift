//
//  YearCalendarGridTheme.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/2/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

public class YearCalendarGridTheme {
    public var insets : CGFloat
    public var interitemSpacing : CGFloat
    public var lineSpacing : CGFloat
    public var titleFontSize : CGFloat
    public var fontSize : CGFloat
    public var textColor: UIColor
    
    static let iPhone5sConfig = YearCalendarGridTheme(insets: 10,
                                                      interitemSpacing: 10,
                                                      lineSpacing: 0,
                                                      titleFontSize: 12,
                                                      fontSize: 8)
    
    static let iPhoneConfig = YearCalendarGridTheme(insets: 10,
                                                    interitemSpacing: 14,
                                                    lineSpacing: 0,
                                                    titleFontSize: 15,
                                                    fontSize: 9)
    
    static let iPhonePlusConfig = YearCalendarGridTheme(insets: 20,
                                                        interitemSpacing: 15,
                                                        lineSpacing: 10,
                                                        titleFontSize: 17,
                                                        fontSize: 10)
    
    static let iPadConfig = YearCalendarGridTheme(insets: 20,
                                                  interitemSpacing: 25,
                                                  lineSpacing: 5,
                                                  titleFontSize: 20,
                                                  fontSize: 14)
    
    
    
    public static let shared : YearCalendarGridTheme = {
        let modelName = UIDevice.modelName
        
        if ["iPhone 5", "iPhone 5s", "iPhone 5c", "iPhone 4", "iPhone 4s", "iPhone SE"].contains(modelName) {
            return iPhone5sConfig
            
        } else if ["iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone X"].contains(modelName) {
            return iPhoneConfig
            
        } else if ["iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus"].contains(modelName) {
            return iPhonePlusConfig
            
        } else  if (UIDevice.current.userInterfaceIdiom == .phone) {
            return iPhoneConfig
            
        } else {
            return iPadConfig
        }
        
    }()
    
    
    init(insets : CGFloat, interitemSpacing : CGFloat, lineSpacing : CGFloat, titleFontSize : CGFloat, fontSize : CGFloat) {
        self.insets = insets
        self.interitemSpacing = interitemSpacing
        self.lineSpacing = lineSpacing
        self.titleFontSize = titleFontSize
        self.fontSize = fontSize
        self.textColor = Theme.textColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
    }
    
    @objc func reloadTheme() {
        self.textColor = Theme.textColor
    }
    
    public func setSharing(_ sharing: Bool) {
        textColor = sharing ? .black : Theme.textColor
    }
    
}


