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
    
    let helper = NSMenuHelper()
    let eventSubmenuGenerator = EventInfoSubmenuGenerator()
    let countdownStringGenerator = CountdownStringGenerator()
    
    func makeEventMenuItem(for event: HLLEvent, needsDateContextInTitle: Bool) -> NSMenuItem {
        
        var title: String
        
        if event.isAllDay == true {
            
            title = "All Day: \(event.title)"
            
        } else {
            
            if let loc = event.location {
                
                title = "\(event.title) (\(loc))"
                
            } else {
                
                title = "\(event.title)"
                
            }
            
            
            
        }
        
        let submenu = eventSubmenuGenerator.generateSubmenuContentsFor(event: event)
        return helper.makeItem(title: title, submenu: submenu, state: .off)
        
    }
    
    func makeCurrentEventMenuItem(for event: HLLEvent) -> NSMenuItem {
        
        let title = countdownStringGenerator.generateCountdownTextFor(event: event)
        let submenu = eventSubmenuGenerator.generateSubmenuContentsFor(event: event)
        let item = helper.makeItem(title: title.combined(), submenu: submenu, state: .off, action: #selector(PrimaryEventManager.shared.currentEventMenuItemClicked(sender:)), target: PrimaryEventManager.shared)
        PrimaryEventManager.shared.addItemWithEvent(item: item, event: event)
        return item
        
    }
    
    func makeNoEventOnMenuItem() -> NSMenuItem {
        
        return helper.makeItem(title: "No Current Events")
        
    }
    
    func makeNoUpcomingMenuItem() -> NSMenuItem {
        
        return helper.makeItem(title: "No Upcoming Events")
        
    }
    
    
    
}
