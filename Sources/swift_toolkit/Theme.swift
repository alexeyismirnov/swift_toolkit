//
//  Theme.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/12/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

public extension Notification.Name {
    static let themeChangedNotification = Notification.Name("THEME_CHANGED")
}

public enum AppStyle: Int {
    case Default=0, Light, Dark
}

public struct Theme {
    public static var textColor: UIColor!
    public static var mainColor : UIColor?
    public static var secondaryColor : UIColor!
    public static let defaultFontSize = CGFloat(UIDevice.current.userInterfaceIdiom == .phone ? 16.0 : 18.0)
    
    public static func set(_ s: AppStyle) {
        switch s {
        case .Default:
            mainColor = nil
            textColor = UIColor.black
            secondaryColor = UIColor.init(hex: "#804000")
            
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]

        case .Light:
            mainColor = UIColor.init(hex: "#edf1f2")
            textColor = UIColor.init(hex: "#000000")
            secondaryColor = UIColor.init(hex: "#804000")
            
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]

        case .Dark:
            mainColor = UIColor.init(hex: "#2b2b2b")
            textColor = UIColor.init(hex: "#ffffff")
            secondaryColor = UIColor.init(hex: "#edf1f2")
            
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        }
    }
    
}
