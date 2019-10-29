//
//  EventMenuItemGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 14/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class EventMenuItemGenerator {
    
    let eventSubmenuGenerator = DetailSubmenuGenerator()
    let countdownStringGenerator = CountdownStringGenerator()
    
    func makeEventInfoMenuItem(for event: HLLEvent, needsDateContextInTitle: Bool) -> NSMenuItem {
        
        var title: String
        
        if event.isAllDay == true {
            
            title = "\(event.title) (All Day)"
            
        } else {
            
            if let loc = event.location {
                
                title = "\(event.title) (\(loc))"
                
            } else {
                
                title = "\(event.title)"
                
            }
            
            
            
        }
        
        
        let submenu = eventSubmenuGenerator.generateInfoSubmenuFor(event: event)
        let item = NSMenuItem()
        
        item.title = title
        item.submenu = submenu
        item.state = .off
        
        if event.completionStatus != .Done, HLLMain.proUser {
        item.target = SelectedEventManager.shared
        item.action = #selector(SelectedEventManager.shared.selectEventFromMenuItem(sender:))
        SelectedEventManager.shared.addItemWithEvent(item: item, event: event)
        }
        
        if SelectedEventManager.selectedEvent == event {
            
            item.state = .on
        }
        
        return item
        
    }
    
    func makeCountdownMenuItem(for event: HLLEvent) -> NSMenuItem {
        
        let title = countdownStringGenerator.generateCountdownTextFor(event: event, showEndTime: false)
        let submenu = eventSubmenuGenerator.generateInfoSubmenuFor(event: event)
        let item = NSMenuItem()
        
        
        item.title = title.combined()
        item.submenu = submenu
        item.state = .off
        
        if SelectedEventManager.selectedEvent == event {
            
            item.state = .on
            
        }
        
        if HLLMain.proUser {
            
        item.action = #selector(SelectedEventManager.shared.selectEventFromMenuItem(sender:))
        item.target = SelectedEventManager.shared
        SelectedEventManager.shared.addItemWithEvent(item: item, event: event)
            
        }
        
        return item
        
    }
    
    func makeNoEventOnMenuItem() -> NSMenuItem {
        
        return NSMenuItem.makeItem(title: "No Current Events")
        
    }
    
    func makeNoUpcomingMenuItem() -> NSMenuItem {
        
        return NSMenuItem.makeItem(title: "No Upcoming Events")
        
    }
    
    
    
}
