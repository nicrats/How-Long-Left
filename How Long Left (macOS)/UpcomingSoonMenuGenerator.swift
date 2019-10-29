//
//  UpcomingSoonMenuGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 16/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class UpcomingSoonMenuGenerator {
    
    let eventItemGen = EventMenuItemGenerator()
    let upcomingStringGen = UpcomingEventStringGenerator()
    
    func generateUpcomingSoonMenuItems(for events: [HLLEvent]) -> [NSMenuItem] {
        
        var items = [NSMenuItem]()
        
        if events.isEmpty == false {
            
            var dateOfLastEvent = Date()
            
            for event in events {
                
                if dateOfLastEvent != event.startDate.startOfDay() {
                    
                    let title = "Upcoming \(event.startDate.userFriendlyRelativeString()):"
                    items.append(NSMenuItem.makeItem(title: title))
                    
                }
            
                items.append(eventItemGen.makeEventInfoMenuItem(for: event, needsDateContextInTitle: true))
                dateOfLastEvent = event.startDate.startOfDay()
                
            }
            
        } else {
            
            items.append(eventItemGen.makeNoUpcomingMenuItem())
            
        }
        
        return items
        
    }
    
    func generateUpcomingSoonMenuItemWithSubmenu(for events: [HLLEvent]) -> NSMenuItem {
        
        var menuItem = NSMenuItem()
    
        if !events.isEmpty {
            
            for event in events {
                
                if SelectedEventManager.selectedEvent == event {
                    
                    menuItem.state = .mixed
                    
                }
                
            }
            
            let menuItemTitle = upcomingStringGen.generateNextEventString(upcomingEvents: events)
            
            let submenu = NSMenu.makeMenu(items: generateUpcomingSoonMenuItems(for: events))
            
            menuItem = NSMenuItem.makeItem(title: menuItemTitle, submenu: submenu, state: .off)
            
        } else {
            
            menuItem = eventItemGen.makeNoUpcomingMenuItem()
            menuItem.submenu = NSMenu()
            menuItem.isEnabled = false
            
        }
        
        return menuItem
    }
    
}
