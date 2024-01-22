//
//  SwifterSwift.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 11/18/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit

public extension String {
    func colored(with color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self).colored(with: color)
    }
}

public extension NSAttributedString {
    
    var centered: NSAttributedString {
        let centerStyle = NSMutableParagraphStyle()
        centerStyle.alignment = .center
        
        return applying(attributes: [.paragraphStyle: centerStyle])
    }
    
    func colored(with color: UIColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }
    
    func font(font: UIFont) -> NSAttributedString {
        return applying(attributes: [.font: font])
    }
    
    func systemFont(ofSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.systemFont(ofSize: CGFloat(ofSize))])
    }
    
    func csFont(ofSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.lang("cs")])
    }
    
    func boldFont(ofSize: CGFloat) -> NSAttributedString {
        return applying(attributes: [.font: UIFont.systemFont(ofSize: CGFloat(ofSize+3), weight: UIFont.Weight.bold)])
    }
    
    fileprivate func applying(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = (string as NSString).range(of: string)
        copy.addAttributes(attributes, range: range)
        
        return copy
    }
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }
    
    static func += (lhs: inout NSAttributedString, rhs: String) {
        lhs += NSAttributedString(string: rhs)
    }
    
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        return lhs + NSAttributedString(string: rhs)
    }
    
}
