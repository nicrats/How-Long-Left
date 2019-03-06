//
//  MacMorningReport.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 1/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class MacMorningReport {
    
    func sendMorningReport() {
        
        let eventSource = EventDataSource()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            let notification = NSUserNotification()
            notification.title = "Good Morning"
            
            let allToday = eventSource.fetchEventsFromPresetPeriod(period: .AllToday)
            
            if let firstEvent = allToday.first {
                
                
                if allToday.count == 1 {
                    
                    notification.informativeText = "Your only event today is \(firstEvent.title)."
                    
                } else {
                    
                    var strings = [String]()
                    
                    for event in allToday {
                        
                        strings.append(event.title)
                        
                    }
                    
                    let listString = strings.joined(separator: ", ")
                    
                    notification.informativeText = "Events today: \(listString)"
                    
                }
                
                
                
            } else {
                
                notification.informativeText = "You have no events on today."
                
            }
            
            NSUserNotificationCenter.default.deliver(notification)
            
            
        })
        
       
        
    }
    
    
}
