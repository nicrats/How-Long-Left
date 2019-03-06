//
//  MilestoneNotifications.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 18/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneNotifications {
    
    let countdownStringGenerator = CountdownStringGenerator()
    let upcomingEventStringGenerator = UpcomingEventStringGenerator()
    let eventData = EventDataSource()
    
    func sendNotificationFor(milestone: Int, event: HLLEvent) {
        
       let upcomingEventText = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: eventData.getUpcomingEventsToday(), currentEvents: eventData.getCurrentEvents(), isForDoneNotification: true)
        
        let notification = NSUserNotification()
        
        if HLLDefaults.notifications.sounds == true {
            notification.soundName = "Hero"
            print("Noto with sound")
        } else {
            
            print("Noto without sound")
            
        }
        
        if milestone == 0 {
            
            notification.title = "\(event.title) is done."
            
        } else {
            
            let countdownTuple = countdownStringGenerator.generateCountdownNotificationStrings(event: event)
            notification.title = countdownTuple.0
            
            if let percent = countdownTuple.1 {
                
                notification.subtitle = "(\(percent) done)"
                
            }
            
        }
        
        notification.informativeText = upcomingEventText
        
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func sendNotificationFor(percentage: Int, event: HLLEvent) {
        
        let upcomingEventText = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: eventData.getUpcomingEventsToday(), currentEvents: eventData.getCurrentEvents(), isForDoneNotification: true)
        
        let notification = NSUserNotification()
        if HLLDefaults.notifications.sounds == true {
        notification.soundName = "Hero"
            print("Noto with sound")
        }
        notification.title = "\(event.title) is \(percentage)% done."
        notification.informativeText = upcomingEventText
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func sendStartingNotification(for event: HLLEvent) {
        
        let upcomingEventText = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: eventData.getUpcomingEventsToday(), currentEvents: eventData.getCurrentEvents(), isForDoneNotification: true)
        
        let notification = NSUserNotification()
        notification.title = "\(event.title) is starting now."
        if HLLDefaults.notifications.sounds == true {
            notification.soundName = "Hero"
            print("Noto with sound")
        }
        notification.informativeText = upcomingEventText
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    
}
