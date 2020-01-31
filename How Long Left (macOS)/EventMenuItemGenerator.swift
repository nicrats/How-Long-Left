//
//  EventMenuItemGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 14/7/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class EventMenuItemGenerator {
    
    let eventSubmenuGenerator = DetailSubmenuGenerator()
    let countdownStringGenerator = CountdownStringGenerator()
    
    func makeEventInfoMenuItem(for event: HLLEvent, needsDateContextInTitle: Bool, isFollowingOccurence: Bool = false) -> NSMenuItem {
        
        let title = event.title.truncated(limit: 30, position: .middle, leader: "...")
        
        var text = title
        
        if let location = event.location?.truncated(limit: 30, position: .middle, leader: "...") {
            
            var locationString = location
            
            if location.contains(text: "Room: ") {
                
                let justRoom = location.components(separatedBy: "Room: ").last!
                locationString = "\(justRoom)"
                
                
            }
            
            if event.roomChange != nil {
                
                locationString = "Changed: \(locationString)"
                
            } else {
                
                locationString = "Room: \(locationString)"
                
            }
            
            text += " (\(locationString))"

        }
        
        if event.isAllDay == true {
            
            text = "\(title) (All-Day)"
            
        }
        
        if isFollowingOccurence {
            
            var relativeDateText = event.startDate.userFriendlyRelativeString()
            
            if let period = event.period {
                
                relativeDateText += ", Period \(period)"
                
            }
            
            text = "\(title) (\(relativeDateText))"
        }
        

        let item = NSMenuItem()
        
        item.title = text
        item.state = .off
        item.submenu = NSMenu()
        
        DispatchQueue.global(qos: .default).async {
            
            let submenu = self.eventSubmenuGenerator.generateInfoSubmenuFor(event: event, isWithinFollowingOccurenceSubmenu: isFollowingOccurence)
            
            DispatchQueue.main.async {
              item.submenu = submenu
            }
            
        }
        
        if event.completionStatus != .Done {
        item.target = SelectionMenuItemHandler.shared
        item.action = #selector(SelectionMenuItemHandler.shared.selectEventFromMenuItem(sender:))
        SelectionMenuItemHandler.shared.addItemWithEvent(item: item, event: event)
        }
        
        if SelectedEventManager.shared.selectedEvent == event {
            
            item.state = .on
        }
        
        return item
        
    }
    
    func makeCountdownMenuItem(for event: HLLEvent) -> NSMenuItem {
        
        let title = countdownStringGenerator.generateCountdownTextFor(event: event, showEndTime: false)
        let item = NSMenuItem()
        
        item.title = title.combined()
        item.state = .off
        
        item.submenu = NSMenu()
        
        DispatchQueue.global(qos: .default).async {
            
            let submenu = self.eventSubmenuGenerator.generateInfoSubmenuFor(event: event)
            
            DispatchQueue.main.async {
              item.submenu = submenu
            }
            
        }
        
        if event.isSelected {
            item.state = .on
        }
            
        item.action = #selector(SelectionMenuItemHandler.shared.selectEventFromMenuItem(sender:))
        item.target = SelectionMenuItemHandler.shared
        SelectionMenuItemHandler.shared.addItemWithEvent(item: item, event: event)
            
        
        
        return item
        
    }
    
    func makeNoEventOnMenuItem() -> NSMenuItem {
        
        return NSMenuItem.makeItem(title: "No Current Events")
        
    }
    
    func makeNoUpcomingMenuItem() -> NSMenuItem {
        
        return NSMenuItem.makeItem(title: "No Upcoming Events")
        
    }
    
    
    
}
