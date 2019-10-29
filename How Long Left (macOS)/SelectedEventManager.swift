//
//  SelectedEventManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 16/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class SelectedEventManager {
    
    static var shared = SelectedEventManager()
    
    static var selectedEvent: HLLEvent? {
        
        didSet {
            
            if let event = SelectedEventManager.selectedEvent {
                
                if event.completionStatus == .Done {
                    
                    SelectedEventManager.selectedEvent = nil
                     print("SelectedSet 4")
                    HLLDefaults.defaults.set(nil, forKey: "SelectedEvent")
                }
                
                
                let id = event.identifier
                
                 HLLDefaults.defaults.set(id, forKey: "SelectedEvent")
                
            } else {
                
                HLLDefaults.defaults.set(nil, forKey: "SelectedEvent")
                
            }
            
            
        }
        
    }
    
    var itemEvents = [NSMenuItem:HLLEvent]()
    
    func removeItems() {
        
        itemEvents.removeAll()
        
    }
    
    func addItemWithEvent(item: NSMenuItem, event: HLLEvent) {
        
        itemEvents[item] = event
        
    }
    
    @objc func clearSelected() {
        
        SelectedEventManager.selectedEvent = nil
        
    }
    
    @objc func selectEventFromMenuItem(sender: NSMenuItem) {
        
        if sender.state == .on {
            
            SelectedEventManager.selectedEvent = nil
             print("SelectedSet 6")
            
            
        } else {
            
            if let eventForSender = itemEvents[sender], let selected = SelectedEventManager.selectedEvent {
                
                if selected == eventForSender {
                    
                    sender.state = .off
                    
                } else {
                    
                    SelectedEventManager.selectedEvent = self.itemEvents[sender]
                     print("SelectedSet 7")
                    
                }
                
                
            } else {
                
                SelectedEventManager.selectedEvent = self.itemEvents[sender]
                 print("SelectedSet 8")
                
            }
            
        }
        
        HLLMain.shared?.mainRunLoop()
        
    }

    
}
