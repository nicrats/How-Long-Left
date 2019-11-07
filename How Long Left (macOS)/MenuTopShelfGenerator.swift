//
//  MenuTopShelfGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class MenuTopShelfGenerator {
    
    let eventItemGen = EventMenuItemGenerator()
    let submenuGen = DetailSubmenuGenerator()
    let upcomingSectionGen = UpcomingSoonMenuGenerator()
    
    func generateTopShelfMenuItems(currentEvents: [HLLEvent], upcomingEventsToday: [HLLEvent]) -> [NSMenuItem] {
        
        let upcomingWillBeShown = HLLDefaults.menu.listUpcoming == true && HLLDefaults.menu.topLevelUpcoming == true
        
        let topLevelUpcoming = upcomingWillBeShown && HLLMain.proUser
        
        var items = [NSMenuItem]()
        
        EventUIWindowsManager.shared.removeItems()
        SelectedEventManager.shared.removeItems()
        
        if let selected = SelectedEventManager.selectedEvent {
          
        var show = true
            
            if !currentEvents.contains(selected) {
            
                if upcomingEventsToday.contains(selected) {
                    
                    if upcomingWillBeShown == true {
                        
                        show = false
                        
                    }
                    
                }
                
            } else {
                
                show = false
                
            }
         
        if show == true {
            
        let item = eventItemGen.makeEventInfoMenuItem(for: selected, needsDateContextInTitle: true)
        item.title = "Selected: \(item.title)"
        items.append(item)
        items.append(NSMenuItem.separator())
                
        }
            
            
        }
        
        
        if currentEvents.isEmpty == false {
            
            /*if topLevelUpcoming {
                
                items.append(NSMenuItem.makeItem(title: "Current:"))
                
            }*/
            
            for event in currentEvents {
                
                let item = eventItemGen.makeCountdownMenuItem(for: event)
                items.append(item)
                
            }
            
        } else {
            
            items.append(eventItemGen.makeNoEventOnMenuItem())
            
        }
        
        if topLevelUpcoming {
            
            items.append(NSMenuItem.separator())
            items.append(contentsOf: upcomingSectionGen.generateUpcomingSoonMenuItems(for: upcomingEventsToday))
        
        } else if HLLDefaults.menu.listUpcoming == true {
           
            items.append(NSMenuItem.separator())
            items.append(upcomingSectionGen.generateUpcomingSoonMenuItemWithSubmenu(for: upcomingEventsToday))
            
        }
        
        if HLLDefaults.calendar.enabledCalendars.isEmpty {
            
            items.removeAll()
            let item = NSMenuItem()
            item.title = "You haven't selected any calendars to use with How Long Left..."
            items.append(item)
            let item2 = NSMenuItem()
            item2.title = "No events will be found until you fix this in Preferences."
            items.append(item2)
            
            
        }

        return items
        
    }
    
    
}
