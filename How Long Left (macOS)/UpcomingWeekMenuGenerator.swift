//
//  UpcomingWeekMenuGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 16/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class UpcomingWeekMenuGenerator {
    
    let eventListGen = EventListMenuGenerator()
    
    func generateUpcomingWeekMenuItem(for days: [DateOfEvents]) -> NSMenuItem {
        
        let submenu = NSMenu()
        
        for dayOfEvents in days {
            
            let item = NSMenuItem()
            
            for event in dayOfEvents.events {
                
                if SelectedEventManager.selectedEvent == event {
                    
                    item.state = .mixed
                    
                }
                
            }
            
            let count = dayOfEvents.events.count
            
            var eventsText = "event"
            if count != 1 {
                eventsText += "s"
            }
            
            item.title = "\(dayOfEvents.date.getDayOfWeekName(returnTodayIfToday: true)) (\(count) \(eventsText))"
            item.submenu = eventListGen.generateEventListMenu(for: dayOfEvents.events, includeDayHeader: false)
            
            if dayOfEvents.events.isEmpty {
                
                item.isEnabled = false
                
            } else {
                
                item.isEnabled = true
                
            }
            
            submenu.addItem(item)
            
            if dayOfEvents.date.startOfDay() == Date().startOfDay() {
                
                submenu.addItem(NSMenuItem.separator())
                
            }
            
        }
        
        let item = NSMenuItem()
        item.title = "Upcoming Week"
        item.submenu = submenu
        return item
        
    }
    
}
