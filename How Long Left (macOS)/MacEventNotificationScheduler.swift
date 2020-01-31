//
//  MacEventNotificationScheduler.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 25/11/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit
import UserNotifications

class MacEventNotificationScheduler: EventPoolUpdateObserver {
    
    let contentGenerator = EventNotificationContentGenerator()
    
    
    init() {
        HLLEventSource.shared.addEventPoolObserver(self)
        scheduleNotificationsForUpcomingEvents()
    }
    
    func scheduleNotificationsForUpcomingEvents() {
        
        DispatchQueue.main.async {
            
            self.removeScheduledNotifications()
        
            let events = HLLEventSource.shared.eventPool.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            let items = self.contentGenerator.generateNotificationContentItems(for: events)
        
            for item in items {
            
                if item.date.timeIntervalSinceNow > 0 {
            
                    if #available(OSX 10.14, *) {
                
                        let notificationContent = UNMutableNotificationContent()
                        notificationContent.userInfo = item.userInfo
                        notificationContent.sound = .default
                        
                        if let title = item.title {
                            notificationContent.title = title
                        }
                            
                        if let subtitle = item.subtitle {
                            notificationContent.subtitle = subtitle
                        }
                            
                        if let body = item.body {
                            notificationContent.body = body
                        }
                        
                        let calendar = Calendar.current
                        let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: item.date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
                        let uuidString = "Scheduled \(UUID().uuidString)"
                        let request = UNNotificationRequest(identifier: uuidString, content: notificationContent, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in })
                        
                        
                    } else {
                
                        let notification = NSUserNotification()
                        notification.deliveryDate = item.date
                        notification.soundName = HLLDefaults.notifications.soundName
                        notification.title = item.title
                        notification.subtitle = item.subtitle
                        notification.informativeText = item.body
                        NSUserNotificationCenter.default.scheduleNotification(notification)
                
                    }
                
                }
            
            }
            
        }
        
    }
    
    func removeScheduledNotifications() {
        
        if #available(OSX 10.14, *) {
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
        } else {
            
            let center = NSUserNotificationCenter.default
            for notification in center.scheduledNotifications {
                center.removeScheduledNotification(notification)
            }
            
        }
        
    }
    
    func eventPoolUpdated() {
        scheduleNotificationsForUpcomingEvents()
    }
    
    
}
