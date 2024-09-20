//
//  BibleModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 3/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import SQLite

public enum BibleLang: Int {
    case slavonic=0, russian
}

struct BibleVerse {
    var verse : Int
    var text: String
}

fileprivate let t_scripture = Table("scripture")

public class BibleUtils {
    public static let f_chapter = SQLite.Expression<Int>("chapter")
    public static let f_verse = SQLite.Expression<Int>("verse")
    public static let f_text = SQLite.Expression<String>("text")
    
    var content : [BibleVerse]
    var bookName : String
    var lang : String
    
    init(bookName : String, lang : String, content: [BibleVerse]) {
        self.bookName = bookName
        self.lang = lang
        self.content = content
    }
    
    public func getAttrText(fontSize:CGFloat) -> NSAttributedString {
        var result = NSAttributedString()
        
        for line in content {
            if bookName == "ps" && (lang == "en" ||  lang == "ru") {
                let text = NSMutableAttributedString(attributedString: line.text.colored(with: Theme.textColor).systemFont(ofSize: fontSize))
                
                if let r = line.text.range(of: ".", options:[], range: nil) {
                    let r2 = line.text.startIndex..<r.upperBound
                    
                    text.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(r2, in: line.text))
                }
                
                result += "\(line.verse) ".colored(with: UIColor.red).systemFont(ofSize: fontSize) + text + "\n"
                
            } else {
                if (lang == "cs") {
                    result += "\(line.verse) ".colored(with: UIColor.red).csFont(ofSize: fontSize)
                        + line.text.colored(with: Theme.textColor).csFont(ofSize: fontSize)

                } else {
                    result += "\(line.verse) ".colored(with: UIColor.red).systemFont(ofSize: fontSize)
                        + line.text.colored(with: Theme.textColor).systemFont(ofSize: fontSize)
                }
                
                result += "\n"
            }
        }
        
        return result
    }
    
    public func getText() -> NSAttributedString {
        NSAttributedString(string: content.map { $0.text }.joined(separator: " "))
    }
    
    static public func fetch(_ name: String, whereExpr: SQLite.Expression<Bool>, lang: String) -> BibleUtils {
        let path = Bundle.main.path(forResource: name.lowercased()+"_"+lang, ofType: "sqlite")!
        let db = try! Connection(path, readonly: true)
        
        var content = [BibleVerse]()
        
        content.append(
            contentsOf: try! db.prepareRowIterator(t_scripture
                .filter(whereExpr)
                .order(f_verse.asc))
            .map { BibleVerse(verse: $0[f_verse], text: $0[f_text]) })

        return BibleUtils(bookName: name, lang: lang, content: content)
    }
}

public protocol BibleModel {
    var items  : [[String]] { get set }
    var filenames  : [[String]] { get set }
    
    func getItems(_ section : Int) -> [String]
    func getNumChapters(_ index : IndexPath) -> Int
    func getTitle(at pos: BookPosition) -> String?
    func getContent(at pos: BookPosition) -> Any?
    
    func getNextSection(at pos: BookPosition) -> BookPosition?
    func getPrevSection(at pos: BookPosition) -> BookPosition?
    
    func getBookmark(at pos: BookPosition) -> String?
    func getBookmarkName(_ bookmark : String) -> String

    func numberOfChapters(_ name: String) -> Int
}

public extension BibleModel where Self:BookModel {
    
    func numberOfChapters(_ name: String) -> Int {
        let path = Bundle.main.path(forResource: name.lowercased()+"_"+lang, ofType: "sqlite")!
        let db = try! Connection(path, readonly: true)
        
        return try! db.scalar(t_scripture.select(BibleUtils.f_chapter.distinct.count))
    }
    
    func getItems(_ section: Int) -> [String] {
        return items[section].map { return Translate.s($0, lang: lang) }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return numberOfChapters(filenames[index.section][index.row])
    }
    
    func getTitle(at pos: BookPosition) -> String? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }
        
        let header = (filenames[index.section][index.row] == "ps")
            ? Translate.s("Kathisma %@", lang: lang)
            : Translate.s("Chapter %@", lang: lang)
        
        return String(format: header, Translate.stringFromNumber(chapter+1))
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        var text = NSAttributedString()

        guard let index = pos.index, let chapter = pos.chapter else { return nil }
        
        let name = filenames[index.section][index.row]
        let prefs = AppGroup.prefs!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        let bu = BibleUtils.fetch(name,
                                  whereExpr: BibleUtils.f_chapter == chapter+1,
                                  lang: lang)
        
        text = bu.getAttrText(fontSize:  CGFloat(fontSize))
        
        return text
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        let chapter = Int(comp[3])!
        
        let header = (filenames[section][row] == "ps")
            ? Translate.s("Kathisma %@", lang: lang)
            : Translate.s("Chapter %@", lang: lang)
        
        let chapterTitle = String(format: header, Translate.stringFromNumber(chapter+1)).lowercased()
        
        return "\(title) - " + Translate.s(items[section][row], lang: lang) + ", \(chapterTitle)"
    }
    
    func getBookmark(at pos: BookPosition) -> String? {
        guard let index = pos.index, let chapter = pos.chapter else { return "" }
        return "\(code)_\(index.section)_\(index.row)_\(chapter)"
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        let numChapters = numberOfChapters(filenames[index.section][index.row])
        if chapter < numChapters-1 {
            return BookPosition(index: index, chapter: chapter+1)
        } else {
            return nil
        }
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        if chapter > 0 {
            return BookPosition(index: index, chapter: chapter-1)
        } else {
            return nil
        }
    }
}

public class OldTestamentModel : BookModel, BibleModel {
    public var lang: String
    
    public var code : String {
        get { return lang == "cs" ? "OldTestamentCS" : "OldTestament" }
    }
    
    public var title: String {
        get { return Translate.s("Old Testament", lang: lang) }
    }
    
    public var author: String?
    public var contentType: BookContentType = .text

    public var hasChapters = true
    
    public var items : [[String]]
    public var filenames : [[String]]

    public init(lang: String) {
        self.lang = lang
        let decoder = JSONDecoder()

        let urlFilenames = Bundle.module.url(forResource: "OldTestamentFilenames", withExtension: "json")!
        filenames = try! decoder.decode([[String]].self, from: try! Data(contentsOf: urlFilenames))
        
        let urlItems = Bundle.module.url(forResource: "OldTestamentItems", withExtension: "json")!
        items = try! decoder.decode([[String]].self, from: try! Data(contentsOf: urlItems))
    }
    
    public func getSections() -> [String] {
        return ["Five Books of Moses", "Historical books", "Wisdom books", "Prophets books"]
            .map { return Translate.s($0, lang: lang) }
    }
    
}

public class NewTestamentModel : BookModel, BibleModel {
    public var lang: String
    
    public var code : String {
        get { return lang == "cs" ? "NewTestamentCS": "NewTestament" }
    }
    
    public var title: String {
        get { return Translate.s("New Testament", lang: lang) }
    }
    
    public var author: String?
    public var contentType: BookContentType = .text

    public var hasChapters = true
    
    public var items : [[String]]
    public var filenames : [[String]]
    
    public init(lang: String) {
        self.lang = lang
        
        let decoder = JSONDecoder()

        let urlFilenames = Bundle.module.url(forResource: "NewTestamentFilenames", withExtension: "json")!
        filenames = try! decoder.decode([[String]].self, from: try! Data(contentsOf: urlFilenames))
        
        let urlItems = Bundle.module.url(forResource: "NewTestamentItems", withExtension: "json")!
        items = try! decoder.decode([[String]].self, from: try! Data(contentsOf: urlItems))
    }
        
    public func getSections() -> [String] {
        return ["Four Gospels and Acts", "Catholic Epistles", "Epistles of Paul", "Apocalypse"]
            .map { return Translate.s($0, lang: lang) }
    }
    
}

