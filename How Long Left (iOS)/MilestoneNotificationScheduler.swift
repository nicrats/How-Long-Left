//
//  MilestoneNotificationScheduler.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 4/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class MilestoneNotificationScheduler {

    let cal = EventDataSource.shared
    var hasPermission = false
    
    init() {
        
        getAccess()
        
    }
    
    func getAccess() {
        
      let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            
            self.hasPermission = granted
        }
        
    }
    
    func scheduleTestNotification() {
        
        
        
        if self.hasPermission == false { return }
        
                let content = UNMutableNotificationContent()
                content.subtitle = "Test notification"
                let date = Date().addingTimeInterval(5.0)
                let calendar = Calendar.current
                let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString,
                                 
                                                    
                                                    content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    
                    print(error.debugDescription)
                    
                })
    }
    
    func scheduleNotificationsForUpcomingEvents() {
        
        
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            
            DispatchQueue.main.async {
            
            self.hasPermission = granted
            
            
            
            if granted == true, UIApplication.shared.backgroundRefreshStatus == .available {
            
                print("Scheduling notifications with milestones \(HLLDefaults.notifications.milestones)")
                
                var eventsArray = self.cal.getCurrentEvents()
                eventsArray.append(contentsOf: self.cal.getUpcomingEventsToday())
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            for event in eventsArray {
                
                for milestone in HLLDefaults.notifications.milestones {
                    
                    let milestoneMin = milestone/60
                    
                    
                    let content = UNMutableNotificationContent()
                    
                    if milestoneMin == 0 {
                        
                        content.body = "\(event.title) is done."
                        
                    } else {
                        
                        var minText = "minutes"
                        
                        if milestoneMin == 1 {
                            
                            minText = "minute"
                            
                        }
                        
                        content.body = "\(event.title) ends in \(milestoneMin) \(minText)."
                        
                    }
                                    
                    let negativeMilestone = 0 - milestone
                    let date = event.endDate.addingTimeInterval(TimeInterval(negativeMilestone))
                    let calendar = Calendar.current
                    let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString,
                                                        content: content, trigger: trigger)
                    
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        
                        print(error.debugDescription)
                        
                    })
                    
                }
                
             /*   for percentageMilestone in HLLDefaults.notifications.Percentagemilestones {
                    
                    
                    
                } */
                
            }
            
            
        }
        
        }
            
        }
        
        
    }
    
    
    
}
