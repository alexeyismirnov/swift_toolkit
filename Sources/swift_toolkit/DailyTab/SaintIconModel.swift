//
//  SaintIcons.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/5/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import class Foundation.Bundle
import struct Foundation.Date
import SQLite

enum IconCodes: Int {
    case pascha=100000, palmSunday=100001, ascension=100002, pentecost=100003,
    theotokosIveron=2250, theotokosLiveGiving=100100, theotokosDubenskaya=100101, theotokosChelnskaya=100103,
    theotokosWall=100105, theotokosSevenArrows=100106, theotokosTabynsk=100108, theotokosKursk=100114
}

public struct SaintIcon {
    public var id : Int
    public var name : String
    public var has_icon : Bool
    public var day : Int
    public var month : Int
    
    public init(id: Int, name: String, has_icon: Bool, day: Int = 0, month: Int = 0) {
        self.id = id
        self.name = name
        self.has_icon = has_icon
        self.day = day
        self.month = month
    }
}

public struct SaintIconModel {
    static let db = try! Connection(Bundle.main.path(forResource: "icons", ofType: "sqlite")!, readonly: true)
    static let app_saint = Table("app_saint")
    static let link_saint = Table("link_saint")

    static let id = SQLite.Expression<Int64>("id")
    static let day = SQLite.Expression<Int64>("day")
    static let month = SQLite.Expression<Int64>("month")
    static let has_icon = SQLite.Expression<Int64>("has_icon")
    static let name = SQLite.Expression<String>("name")
    
    static func addSaints(date: Date) -> [SaintIcon] {
        var saints = [SaintIcon]()
        
        let day_num = Int64(date.day)
        let month_num = Int64(date.month)
        
        saints.append(
            contentsOf: try! db.prepareRowIterator(app_saint
                .filter(month == month_num && day == day_num && has_icon == 1))
                .map { SaintIcon(id: Int(exactly: $0[id])!, name: $0[name], has_icon: true) }
        )
        
        saints.append(
            contentsOf: try! db.prepareRowIterator(app_saint
                .join(link_saint,
                    on: link_saint[month] == month_num && link_saint[day] == day_num && app_saint[id] == link_saint[id]))
            .map { SaintIcon(id: Int(exactly: $0[app_saint[id]])!, name: $0[link_saint[name]], has_icon: true) }
        )
        
        return saints
    }
    
    static public func get(_ date: Date) -> [SaintIcon] {
        var saints = [SaintIcon]()
        let year = date.year
        
        let cal = Cal.fromDate(date)
        let pascha = cal.pascha
        
        let moveableIcons : [Date: [IconCodes]] = [
            pascha-7.days:      [.palmSunday],
            pascha:             [.pascha],
            pascha+2.days:      [.theotokosIveron],
            pascha+39.days:     [.ascension],
            pascha+49.days:     [.pentecost],
            pascha+5.days:      [.theotokosLiveGiving],
            pascha+24.days:     [.theotokosDubenskaya],
            pascha+42.days:     [.theotokosChelnskaya],
            pascha+56.days:     [.theotokosWall, .theotokosSevenArrows],
            pascha+61.days:     [.theotokosTabynsk, .theotokosKursk],
        ]
        
        if let codes = moveableIcons[date] {
            for code in codes {
                saints.append(
                    contentsOf: try! db.prepareRowIterator(app_saint
                        .filter(id == Int64(code.rawValue)))
                    .map { SaintIcon(id: code.rawValue, name: $0[name], has_icon: true) }
                )
            }
        }
         
        if cal.isLeapYear {
            switch date {
            case cal.leapStart ..< cal.leapEnd:
                saints += addSaints(date: date+1.days)
                break
                
            case cal.leapEnd:
                saints += addSaints(date: Date(29, 2, year))
                break
                
            default:
                saints += addSaints(date: date)
            }
        } else {
            saints += addSaints(date: date)
            
            if date == cal.leapEnd {
                saints += addSaints(date: Date(29, 2, 2000))
            }
        }
        
        return saints

    }
    
}

