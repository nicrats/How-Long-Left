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
    let submenuGen = EventInfoSubmenuGenerator()
    let helper = NSMenuHelper()
    
    func generateTopShelfMenuItems(currentEvents: [HLLEvent], upcomingEventsToday: [HLLEvent]) -> [NSMenuItem] {
        
        var items = [NSMenuItem]()
        
        EventUIWindowsManager.shared.removeItems()
        PrimaryEventManager.shared.removeItems()
        
        let listMode = HLLDefaults.menu.listUpcoming == true && HLLDefaults.menu.topLevelUpcoming == true
        
        if currentEvents.isEmpty == false {
            
            if listMode {
                
                items.append(helper.makeItem(title: "Current"))
                
            }
            
            for event in currentEvents {
                
                let item = eventItemGen.makeCurrentEventMenuItem(for: event)
                if PrimaryEventManager.primaryEvent == event {
                    item.state = .on
                }
                
                items.append(item)
                
            }
            
        } else {
            
            items.append(eventItemGen.makeNoEventOnMenuItem())
            
        }
        
        if listMode {
            
            items.append(NSMenuItem.separator())
            
        }
        
        if upcomingEventsToday.isEmpty == false, listMode {
            
            var dateOfLastEvent = Date()
            
            for event in upcomingEventsToday {
                    
                    if dateOfLastEvent != event.startDate.midnight() {
                        
                        var title = event.startDate.userFriendlyRelativeString()
                        
                        if event.startDate.midnight() == Date().midnight() {
                            
                            title = "Upcoming \(title)"
                            
                        }
                        
                        items.append(helper.makeItem(title: title))
                        
                    }
                
                items.append(eventItemGen.makeEventMenuItem(for: event, needsDateContextInTitle: true))
                dateOfLastEvent = event.startDate.midnight()
                
            }
            
            
        } else if listMode {

            items.append(eventItemGen.makeNoUpcomingMenuItem())
            
        }

        return items
        
    }
    
}
