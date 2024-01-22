//
//  AppGroup.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 7/29/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import Foundation

public struct AppGroup {
    static public var id: String! {
        didSet {
            url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
            prefs = UserDefaults(suiteName: id)!
        }
    }
    
    static public var url : URL!
    static public var prefs : UserDefaults!
    
    static public func copyFile(_ filename: String, _ ext: String)  {
        let srcPath = Bundle.main.url(forResource: filename, withExtension: ext)!
        let dstPath = url.appendingPathComponent(filename+"."+ext)
        
        do {
            let data = try Data(contentsOf: srcPath)
            try data.write(to: dstPath, options: .atomic)
            
        } catch let error as NSError  {
            print(error.description)
        }
    }
}
