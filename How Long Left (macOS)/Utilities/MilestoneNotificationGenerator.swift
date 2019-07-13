//
//  MilestoneNotifications.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 18/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneNotificationGenerator {
    
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
            
            let item = countdownStringGenerator.generateCountdownTextFor(event: event)
            notification.title = item.mainText
            
            if let percent = item.percentageText {
                
                
                notification.subtitle = "(\(percent) done)"
                
                
                if milestone == 60, SchoolAnalyser.schoolMode == .Magdalene {
                    
                    notification.subtitle = "We're in the endgame now"
                    
                    
                }
                
                
                
                
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
        }
        notification.informativeText = upcomingEventText
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    
}
