//
//  EventNotificationScheduler.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 4/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class MilestoneNotificationScheduler {
    
    var hasPermission = true
    
    init() {
        getAccess()
    }
    
    func getAccess() {
        
      let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        
        
        center.requestAuthorization(options: [.alert, .sound, .badge])
        { (granted, error) in
            
            self.hasPermission = granted
        }
        
    }
    
    
    func scheduleTestNotification() {
        
        
        if self.hasPermission == false { return }
        
                let content = UNMutableNotificationContent()
                content.sound = .default
                content.subtitle = "Test notification"
                let date = Date().addingTimeInterval(6.0)
        
                let calendar = Calendar.current
                let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString,
                                 
                                                    
                                                    content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    
                 //   print(error.debugDescription)
                    
                })
    }
    
    func scheduleNotificationsForUpcomingEvents() {
        
        
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound, .badge])
        { (granted, error) in
            
            DispatchQueue.main.sync {
            
            self.hasPermission = granted
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            if granted == true, UIApplication.shared.backgroundRefreshStatus == .available {
            
              //  print("Scheduling notifications with milestones \(HLLDefaults.notifications.milestones)")
                
                var eventsArray = HLLEventSource.shared.getCurrentEvents()
                eventsArray.append(contentsOf: HLLEventSource.shared.getUpcomingEventsToday())
            
          UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            for event in eventsArray {
                
                for milestone in HLLDefaults.notifications.milestones {
                    
                    let milestoneMin = milestone/60
                    
                    
                    let content = UNMutableNotificationContent()
                    content.sound = .default
                    
                    if milestoneMin == 0 {
                        
                        content.title = "\(event.title) is done."
                        
                    } else {
                        
                        var minText = "minutes"
                        
                        if milestoneMin == 1 {
                            
                            minText = "minute"
                            
                        }
                        
                        content.title = "\(event.title) \(event.countdownStringEnd) in \(milestoneMin) \(minText)."
                        
                    }
                                    
                    let negativeMilestone = 0 - milestone
                    let date = event.endDate.addingTimeInterval(TimeInterval(negativeMilestone))
                    
                    var subtitleText: String
                    
                    if let nextEvent = self.eventsNotStartedBy(date: date, events: eventsArray).first {
                        
                        var startingTypeText = "next"
                        
                        if nextEvent.startDate == date {
                            
                            startingTypeText = "on now"
                            
                        }
                        
                        subtitleText = "\(nextEvent.title) is \(startingTypeText)."
                        
                        if let loc = nextEvent.location {
                            
                            subtitleText += " (\(loc))"
                            
                        }
                        
                    } else {
                        
                        subtitleText = "Nothing is next."
                        
                    }
                    
                    
                    
                    content.body = subtitleText
                    
                    
                   // print("Subtitle: \(subtitleText)")
                    
                    let calendar = Calendar.current
                    let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString,
                                                        content: content, trigger: trigger)
    
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        
                     //   print(error.debugDescription)
                        
                    })
                    
                }
                
               for percentageMilestone in HLLDefaults.notifications.Percentagemilestones {
                
                let milestoneSecondsFromStart = Int(event.duration)/100*percentageMilestone
                
                let content = UNMutableNotificationContent()
                content.sound = .default
                
                content.title = "\(event.title) is \(percentageMilestone)% done."
                
                
                let date = event.startDate.addingTimeInterval(TimeInterval(milestoneSecondsFromStart))
                
                var subtitleText: String
                
                if let nextEvent = self.eventsNotStartedBy(date: date, events: eventsArray).first {
                    
                    var startingTypeText = "next"
                    
                    if nextEvent.startDate == date {
                        
                        startingTypeText = "on now"
                    
                    }
                    
                    subtitleText = "\(nextEvent.title) is \(startingTypeText)."
                    
                    if let loc = nextEvent.location {
                       
                        subtitleText += " (\(loc))"
                        
                    }
                    
                } else {
                    
                    subtitleText = "Nothing is next."
                    
                }
                    
                content.body = subtitleText
                
               // print("Subtitle: \(subtitleText)")
                
                let calendar = Calendar.current
                let time = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString,
                                                    content: content, trigger: trigger)
                
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    
                  //  print(error.debugDescription)
                    
                })
                
                
                    
                    
                }
                
            }
            
            
            }
        
            }
            
        }
        
        
    }
    
    
    func eventsNotStartedBy(date: Date, events: [HLLEvent]) -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        for event in events {
            
            if event.startDate.timeIntervalSince(date) > -1 {
                
                returnArray.append(event)
                
            }
            
        }
        
        return returnArray
    }
    
    
    
}
