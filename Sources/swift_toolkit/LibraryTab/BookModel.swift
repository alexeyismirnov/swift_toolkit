//
//  BookModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import Foundation

public enum BookContentType: Int {
    case text = 0, html, epub
}

public struct BookPosition: Equatable {
    public init(model: BookModel, index: IndexPath, chapter: Int = 0) {
        self.model = model
        self.index = index
        self.chapter = chapter
    }
    
    public init(model: BookModel, location: String) {
        self.model = model
        self.location = location
    }
    
    public init(model: BookModel, data: Any) {
        self.model = model
        self.data = data
    }
    
    
    public init(index: IndexPath, chapter: Int = 0) {
        self.index = index
        self.chapter = chapter
    }
    
    public var model : BookModel?
    public var index : IndexPath?
    public var chapter : Int?
    public var location: String?
    public var data: Any?
    
    public static func == (lhs: BookPosition, rhs: BookPosition) -> Bool {
        return lhs.index == rhs.index && lhs.chapter == rhs.chapter
    }
}

public protocol BookModel {
    var code : String { get }
    var contentType : BookContentType { get }
    var title: String { get }
    var author: String? { get }

    var lang : String { get set }
    
    var hasChapters : Bool { get }
    
    func getSections() -> [String]
    func getItems(_ section : Int) -> [String]
    
    func getNumChapters(_ index : IndexPath) -> Int
    func getComment(commentId: Int) -> String?
    
    func getTitle(at pos: BookPosition) -> String?
    func getContent(at pos: BookPosition) -> Any?
    
    func getNextSection(at pos: BookPosition) -> BookPosition?
    func getPrevSection(at pos: BookPosition) -> BookPosition?
    
    func getBookmark(at pos: BookPosition) -> String?
    func getBookmarkName(_ bookmark : String) -> String
}

public extension BookModel {
    func getNextSection(at pos: BookPosition) -> BookPosition? { return nil }
    func getPrevSection(at pos: BookPosition) -> BookPosition? { return nil }
    
    func getTitle(at pos: BookPosition) -> String? { return nil }
    func getComment(commentId: Int) -> String? { return nil }

    func getBookmark(at pos: BookPosition) -> String? { return nil }
    func getBookmarkName(_ bookmark : String) -> String { return "" }
}

public protocol ServiceModel: BookModel {
    var date : Date { get set }
    func dateIterator(startDate: Date) -> AnyIterator<Date>
}

public extension ServiceModel {
    func dateIterator(startDate: Date) -> AnyIterator<Date> {
        return AnyIterator({ return nil })
    }
}
