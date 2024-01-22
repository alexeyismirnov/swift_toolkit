//
//  EbookModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/13/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import SQLite

open class EbookModel : BookModel {
    public var code: String
    public var title: String
    public var author: String?
    public var contentType: BookContentType
    
    public var hasChapters = false
    public var lang = Translate.language
    
    public var db : Connection
    
    let t_data = Table("data")
    let t_content = Table("content")
    let t_sections = Table("sections")
    let t_comments = Table("comments")

    let f_id = Expression<Int>("id")
    let f_section = Expression<Int>("section")
    let f_item = Expression<Int>("item")

    let f_title = Expression<String>("title")
    let f_text = Expression<String>("text")

    let f_key = Expression<String>("key")
    let f_value = Expression<String>("value")
    
    lazy var sections: [String] = {
        return try! db.prepareRowIterator(t_sections
            .order(f_id.asc))
        .map { $0[f_title] }
    }()
    
    public var items = [Int:[String]]()

    public init(_ filename: String) {
        let path = Bundle.main.path(forResource: filename, ofType: "sqlite")!
        db = try! Connection(path, readonly: true)
        
        code = try! db.pluck(t_data.filter(f_key == "code"))![f_value]
        title = try! db.pluck(t_data.filter(f_key == "title"))![f_value]
        author = try! db.pluck(t_data.filter(f_key == "author"))?[f_value]
        
        contentType = BookContentType(
            rawValue: Int(try! db.pluck(t_data.filter(f_key == "contentType"))![f_value])!)!
    }
    
    public func getSections() -> [String] {
        return sections
    }
    
    public func getItems(_ section: Int) -> [String] {
        if items[section] != nil { return items[section]! }
        
        items[section] = try! db.prepareRowIterator(t_content
            .filter(f_section == section)
            .order(f_item.asc))
        .map { $0[f_title] }
        
        return items[section]!
    }
    
    public func getTitle(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return nil }
        return try! db.pluck(t_content
            .filter(f_section == index.section && f_item == index.row))![f_title]
    }
    
    public func getNumChapters(_ index: IndexPath) -> Int {
        return try! db.scalar(t_content.select(f_title.distinct.count))
    }
    
    public func getComment(commentId: Int) -> String? {
        return try! db.pluck(t_comments.filter(f_id == commentId))![f_text]
    }
    
    open func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        
        var text = try! db.pluck(t_content
            .filter(f_section == index.section && f_item == index.row))![f_text]
        
        if (contentType == .text) {
            let fontSize = CGFloat(AppGroup.prefs.integer(forKey: "fontSize"))
            return  NSAttributedString(string: text)
                .font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
                .colored(with:Theme.textColor)
            
        } else {
            let pattern = "comment_(\\d+)"
            let regex = try! NSRegularExpression(pattern: pattern)
            
            if regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).count > 0 {
                let text2 = NSMutableString(string: text)
                
                regex.replaceMatches(in: text2, options: .reportProgress, range: NSRange(location: 0,length: text2.length), withTemplate: "&nbsp;&nbsp;<a href=\"comment://$1\"><img class=\"icon\"/></a>&nbsp;&nbsp;")
                
                text = String(text2)
            }
            
            return text
        }
    }
    
    public func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }

        let items = getItems(index.section)
        
        if index.row+1 == items.count {
            if index.section+1 == sections.count {
                return nil
            } else {
                return BookPosition(index: IndexPath(row: 0, section: index.section+1))
            }
        } else {
            return BookPosition(index: IndexPath(row: index.row+1, section: index.section))
        }
        
    }
    
    public func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }

        if index.row == 0 {
            if index.section == 0 {
                return nil
            } else {
                let items = getItems(index.section-1)
                return BookPosition(index: IndexPath(row: items.count-1, section: index.section-1))
            }
        } else {
            return BookPosition(index: IndexPath(row: index.row-1, section: index.section))
        }
    }
    
    public func getBookmark(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return nil }
        return "\(code)_\(index.section)_\(index.row)"
    }
    
    public func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        
        let sectionTitle = getTitle(at: BookPosition(index: IndexPath(row: row, section: section)))!
        
        return "\(title) - \(sectionTitle)"
    }
}

