//
//  EventUIWindowsManager.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 16/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class EventUIWindowsManager: NSObject, NSWindowDelegate {
    
    static var shared = EventUIWindowsManager()
    
    var eventUIWindowControllers = [String:NSWindowController]()
    var eventUIStoryboard = NSStoryboard(name: "EventUIStoryboard", bundle: nil)
    var existingEventUIButtons = [NSMenuItem:HLLEvent]()
    
    func removeItems() {
        
        existingEventUIButtons.removeAll()
        
    }
    
    func addItemWithEvent(item: NSMenuItem, event: HLLEvent) {
        
        existingEventUIButtons[item] = event
        
    }
    
    
    
    @objc func eventUIButtonClicked(sender: NSMenuItem) {
        
        if let event = existingEventUIButtons[sender] {
            
          launchWindowFor(event: event)
            
        }
        
    }
    
    func launchWindowFor(event: HLLEvent) {
        
        var id: String
        
        if let ekID = event.EKEvent?.eventIdentifier {
            
            id = ekID
            
        } else {
            
            id = event.identifier
            
        }
        
        
        if let window = eventUIWindowControllers[id] {
            
            NSApp.activate(ignoringOtherApps: true)
            window.window?.delegate = self
            window.showWindow(self)
            
        } else {
            
            let vc = self.eventUIStoryboard.instantiateController(withIdentifier: "MainUI") as? NSWindowController
            vc?.window?.delegate = self
            
            
            (vc!.contentViewController?.children.first as! EventUITabViewController).event = event
            
            eventUIWindowControllers[id] = vc
            
            if let window = eventUIWindowControllers[id] {
                
                NSApp.activate(ignoringOtherApps: true)
                window.window?.delegate = self
                window.showWindow(self)
                window.window?.center()
                
                
            }
            
        }
        
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        for keyValue in eventUIWindowControllers {
            
            if keyValue.value == sender.windowController! {
                
                
                eventUIWindowControllers.removeValue(forKey: keyValue.key)
                
            }
            
        }
        
        return true
        
    }
    
}
