//
//  FeastNotifications.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/30/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import UserNotifications

open class FeastNotifications {
    static let center = UNUserNotificationCenter.current()

    open class func addNotification(date: Date, title: String, body: String) {
        var components: DateComponents!
    
        components = DateComponents(date: date-1.days)
        components.hour = 17
        components.minute = 00
   
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    open class func setupExtraNotifications() {}
    
    open class func setupNotifications() {
        let prefs = AppGroup.prefs!

        let year = Calendar.current.component(.year, from: Date())
        let fl = FeastList.from(year)
        let cal = Cal.fromDate(Date(1, 1, year))
                
        if prefs.bool(forKey: "notifications_\(year)") {
            return
        }

        prefs.set(true, forKey: "notifications_\(year)")
        prefs.synchronize()

        center.requestAuthorization(options:  [.alert, .sound]) {
            (granted, error) in
            if granted {
                center.removeAllPendingNotificationRequests()
                
                for (date, descr) in fl.longFasts {
                    addNotification(date: date, title: "", body: descr.string)
                }
                
                for (date, descr) in fl.shortFasts {
                    addNotification(date: date, title: Translate.s("fast_day"), body: descr.string)
                }
                
                for (date, descr) in fl.fastFreeWeeks {
                    addNotification(date: date, title: Translate.s("fast_free"), body: descr.string)
                }
                 
                for (date, descr) in fl.movableFeasts {
                    addNotification(date: date, title: "", body: descr.string)
                }
                
                for (date, descr) in fl.nonMovableFeasts {
                    if (date == cal.d("exaltationOfCross")) {
                        // print("cross")
                    } else {
                        addNotification(date: date, title: "", body: descr.string)
                    }
                }
                
                for (date, descr) in fl.greatFeasts {
                    if (date == cal.d("beheadingOfJohn")) {
                        // print("beheading")
                    } else {
                        addNotification(date: date, title: "", body: descr.string)
                    }
                }
                
                setupExtraNotifications()

                center.getPendingNotificationRequests { (notifications) in
                    print("Count: \(notifications.count)")
                    for item in notifications {
                        let trigger = item.trigger as! UNCalendarNotificationTrigger
                        
                        // print(trigger.nextTriggerDate())
                        // print(item.content)
                    }
                }
                
            }
        }
    }
    
}

