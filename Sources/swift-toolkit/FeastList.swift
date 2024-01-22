//
//  FeastList.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/29/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit

public class FeastList {
    var formatter1: DateFormatter { get {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        switch Translate.language {
        case "ru":
            formatter.dateFormat = "cccc, d MMMM"
            break
        case "cn",
             "hk":
            formatter.dateFormat = "M月d日"
            break
        default:
            formatter.dateFormat = "EEEE, MMM d"
        }
        formatter.locale = Translate.locale
        
        return formatter
        }
    }
    
    var formatter2: DateFormatter { get {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        switch Translate.language {
        case "ru":
            formatter.dateFormat = "d MMMM"
            break
        case "cn",
             "hk":
            formatter.dateFormat = "M月d日"
            break
        default:
            formatter.dateFormat = "MMMM d"
        }
        formatter.locale = Translate.locale
        
        return formatter
        }
    }
    
    public var sharing: Bool = false {
        didSet { update() }
    }
    
    public var textFontSize : CGFloat!
    public var textFontColor : UIColor!
    
    public var longFasts : [Date: NSAttributedString]!
    public var shortFasts : [Date: NSAttributedString]!
    public var fastFreeWeeks : [Date: NSAttributedString]!
    public var movableFeasts : [Date: NSAttributedString]!
    public var nonMovableFeasts : [Date: NSAttributedString]!
    public var greatFeasts : [Date: NSAttributedString]!
    public var remembrance : [Date: NSAttributedString]!
    
    var year: Int
    var cal: Cal
    
    static var lists = [Int:FeastList]()
    
    static public func from(_ year: Int) -> FeastList {
        if lists[year] == nil {
            lists[year] = FeastList(year)
        }
        
        return lists[year]!
    }
    
    func makeFeastStr(code: String, color: UIColor? = nil) -> NSAttributedString  {
        let day = cal.day(code)
        let dateStr = formatter1.string(from: day.date!).capitalizingFirstLetter()
        let feastStr = day.name
        
        return "\(dateStr) — \(feastStr)\n\n".colored(with: color ?? textFontColor).systemFont(ofSize: textFontSize)
    }
    
    func makeIntervalStr(fromDate: Date, toDate: Date, descr : String) -> NSAttributedString  {
        let d1 = formatter2.string(from: fromDate)
        let d2 = formatter2.string(from: toDate)
        
        return (String(format: Translate.s("From %@ till %@ — %@"), d1, d2, descr) + "\n\n")
            .colored(with: textFontColor)
            .systemFont(ofSize: textFontSize)
    }
    
    init(_ year: Int) {
        self.year = year
        self.cal = Cal.fromDate(Date(1, 1, year))
        
        update()
    }
    
    func update() {
        textFontSize = sharing ? CGFloat(12) : CGFloat(16)
        textFontColor = sharing ? UIColor.black :Theme.textColor

        longFasts = [
            cal.d("beginningOfGreatLent") : makeIntervalStr(fromDate: cal.greatLentStart,
                                                       toDate: cal.greatLentStart + 47.days,
                                                       descr: Translate.s("great_lent")),
            
            cal.d("beginningOfApostlesFast") : makeIntervalStr(fromDate: cal.d("beginningOfApostlesFast"),
                                                           toDate: cal.d("peterAndPaul") - 1.days,
                                                           descr: Translate.s("apostles_fast")),
            
            cal.d("beginningOfDormitionFast") : makeIntervalStr(fromDate: cal.d("beginningOfDormitionFast"),
                                                           toDate: cal.d("dormition") - 1.days,
                                                           descr: Translate.s("dormition_fast")),
            
            cal.d("beginningOfNativityFast") : makeIntervalStr(fromDate: cal.d("beginningOfNativityFast"),
                                                          toDate: cal.d("nativityOfGod") - 1.days,
                                                          descr: Translate.s("nativity_fast"))]
        
        shortFasts = [cal.d("eveOfTheophany") :  makeFeastStr(code: "eveOfTheophany"),
                      cal.d("beheadingOfJohn") :  makeFeastStr(code: "beheadingOfJohn"),
                      cal.d("exaltationOfCross") :  makeFeastStr(code: "exaltationOfCross")]
        
        fastFreeWeeks = [
            cal.d("nativityOfGod") : makeIntervalStr(fromDate: cal.d("nativityOfGod"),
                                                toDate: cal.d("eveOfTheophany") - 1.days,
                                                descr: Translate.s("svyatki")),
            
            cal.d("sundayOfPublicianAndPharisee")+1.days : makeIntervalStr(fromDate: cal.d("sundayOfPublicianAndPharisee")+1.days,
                                                                      toDate: cal.d("sundayOfProdigalSon"),
                                                                      descr: Translate.s("weekOfPublicianAndPharisee")),
            
            cal.d("sundayOfDreadJudgement")+1.days : makeIntervalStr(fromDate: cal.d("sundayOfDreadJudgement")+1.days,
                                                                toDate: cal.greatLentStart-1.days,
                                                                descr: Translate.s("maslenitsa")),
            
            cal.pascha+1.days : makeIntervalStr(fromDate: cal.pascha+1.days,
                                                toDate: cal.pascha+7.days,
                                                descr: Translate.s("brightWeek")),
            
            cal.pentecost+1.days : makeIntervalStr(fromDate: cal.pentecost+1.days,
                                                   toDate: cal.pentecost+7.days,
                                                   descr: Translate.s("trinityWeek"))]
        
        movableFeasts = Dictionary(uniqueKeysWithValues:
            ["palmSunday", "ascension", "pentecost"].map{ (cal.d($0), makeFeastStr(code: $0)) })
        
        nonMovableFeasts = Dictionary(uniqueKeysWithValues:
            ["nativityOfGod", "theophany", "meetingOfLord", "annunciation", "transfiguration", "dormition",
            "nativityOfTheotokos", "exaltationOfCross", "entryIntoTemple"]
                                        .map{ (cal.d($0), makeFeastStr(code: $0)) })

        greatFeasts = Dictionary(uniqueKeysWithValues:
            ["circumcision", "nativityOfJohn", "peterAndPaul", "beheadingOfJohn", "veilOfTheotokos"]
                                    .map{ (cal.d($0), makeFeastStr(code: $0)) })
        
        remembrance = Dictionary(uniqueKeysWithValues:
            ["newMartyrsConfessorsOfRussia", "saturdayOfDeparted", "radonitsa",
             "killedInAction", "saturdayTrinity", "demetriusSaturday" ]
                                    .map{ (cal.d($0), makeFeastStr(code: $0)) })
                                    
    }
}
