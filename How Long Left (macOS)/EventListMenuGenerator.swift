//
//  EventListMenuGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 14/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class EventListMenuGenerator {
    
    let eventItemGen = EventMenuItemGenerator()
    let helper = NSMenuHelper()
    
    func generateEventListMenu(for events: [HLLEvent], includeDayHeader: Bool) -> NSMenu {
        
        var dateOfLastEvent = Date()
        
        var items = [NSMenuItem]()
        
        for event in events {
            
            if includeDayHeader == true {
            
            if dateOfLastEvent != event.startDate.midnight() {
                
                var title = event.startDate.userFriendlyRelativeString()
                
                if event.startDate.midnight() == Date().midnight() {
                    
                    title = "Upcoming \(title)"
                    
                }
                
                let menuItem = helper.makeItem(title: "\(title):")
                items.append(menuItem)
                
                }
                
            }
            
            let menuItem = eventItemGen.makeEventMenuItem(for: event, needsDateContextInTitle: true)
            items.append(menuItem)
            
            dateOfLastEvent = event.startDate.midnight()
            
        }
        
        return helper.makeMenu(items: items)
    }
    
    
}
