//
//  PericopeModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import SQLite

public class PericopeModel : BookModel {
    public var lang: String
    
    public var code : String = "Pericope"
    public var title = ""
    public var author: String?
    public var contentType: BookContentType = .text

    public var hasChapters = false
    
    var allItems, allFilenames : [String]
    
    public init(lang: String) {
        self.lang = lang
        
        let model1 = OldTestamentModel(lang: lang)
        let model2 = NewTestamentModel(lang: lang)

        allItems = (model1.items + model2.items).flatMap { $0 }
        allFilenames = (model1.filenames + model2.filenames).flatMap { $0 }
    }
    
    public func getPericope(_ str: String, decorated: Bool = true) -> [(NSAttributedString, NSAttributedString)] {
        var result = [(NSAttributedString, NSAttributedString)]()
        let prefs = AppGroup.prefs!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        
        let pericope = str.split { $0 == " " }.map { String($0) }
        
        for i in stride(from: 0, to: pericope.count-1, by: 2) {
            var chapter: Int = 0
            
            let fileName = pericope[i].lowercased()
            let item = allItems[allFilenames.firstIndex(of: fileName)!]
                        
            var bookName = NSAttributedString()
            var text = NSAttributedString()
            
            if decorated {
                bookName = (Translate.s(item, lang: lang) + " " + pericope[i+1]).colored(with: Theme.textColor)
                
                if (lang == "cs") {
                    bookName = bookName
                        .csFont(ofSize: fontSize)
                        .centered
                    
                } else {
                    bookName = bookName
                        .boldFont(ofSize: fontSize)
                        .centered
                }
                  
                
            } else {
                bookName = NSAttributedString(string: Translate.s(item, lang: lang))
            }
            
            let arr2 = pericope[i+1].components(separatedBy: ",")
            
            for segment in arr2 {
                var range: [(Int, Int)]  = []
                
                let arr3 = segment.components(separatedBy: "-")
                for offset in arr3 {
                    let arr4 = offset.components(separatedBy: ":")
                    
                    if arr4.count == 1 {
                        range += [ (chapter, Int(arr4[0])!) ]
                        
                    } else {
                        chapter = Int(arr4[0])!
                        range += [ (chapter, Int(arr4[1])!) ]
                    }
                }
                
                if range.count == 1 {
                    let bu = BibleUtils.fetch(fileName,
                                              whereExpr: BibleUtils.f_chapter == range[0].0 && BibleUtils.f_verse == range[0].1,
                                              lang: lang)
                    
                    text += decorated ? bu.getAttrText(fontSize: fontSize) : bu.getText()
                    
                } else if range[0].0 != range[1].0 {
                    
                    var bu = BibleUtils.fetch(fileName,
                                              whereExpr: BibleUtils.f_chapter == range[0].0 && BibleUtils.f_verse >= range[0].1,
                                              lang: lang)
                    
                    text += decorated ? bu.getAttrText(fontSize: fontSize) : bu.getText()

                    for chap in range[0].0+1 ..< range[1].0 {
                        bu = BibleUtils.fetch(fileName,
                                              whereExpr: BibleUtils.f_chapter == chap,
                                              lang: lang)
                        
                        text += decorated ? bu.getAttrText(fontSize: fontSize) : bu.getText()
                    }
                    
                    bu = BibleUtils.fetch(fileName,
                                          whereExpr: BibleUtils.f_chapter == range[1].0 && BibleUtils.f_verse <= range[1].1,
                                          lang: lang)
                    
                    text += decorated ? bu.getAttrText(fontSize: fontSize) : bu.getText()
                    
                } else {
                    let bu = BibleUtils.fetch(fileName,
                                               whereExpr: 
                                                BibleUtils.f_chapter == range[0].0 &&
                                                BibleUtils.f_verse >= range[0].1 &&
                                                BibleUtils.f_verse <= range[1].1,
                                              lang: lang)
                    
                    text += decorated ? bu.getAttrText(fontSize: fontSize) : bu.getText()
                    
                }
            }
            
            text += "\n"
            result += [(bookName, text)]
        }
        
        return result
    }
        
    public func getSections() -> [String] {
        return []
    }
    
    public func getItems(_ section: Int) -> [String] {
        return []
    }

    public func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    public func getContent(at pos: BookPosition) -> Any? {
        guard let str = pos.location else { return nil }
        let pericope = getPericope(str.trimmingCharacters(in: CharacterSet.whitespaces))
        
        var text = NSAttributedString()
        
        for (title, content) in pericope {
            text +=  title + "\n\n" + content + "\n"
        }
        
        return text
    }
    
}

