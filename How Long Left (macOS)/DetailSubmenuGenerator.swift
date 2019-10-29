//
//  DetailSubmenuGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 8/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class DetailSubmenuGenerator {
    
    var countdownStringGen = CountdownStringGenerator()
    
    func generateInfoSubmenuFor(event: HLLEvent, hideNextOccur: Bool = false ) -> NSMenu {

        let menu = NSMenu()
        
        var arrayOne = [String]()
        
        switch event.completionStatus {
            
        case .Upcoming:
    
        let startsInText = countdownStringGen.generateCountdownTextFor(event: event).justCountdown
        arrayOne.append("\(event.title) - In \(startsInText)")
            
        case .Current:
            arrayOne.append("On Now: \(event.title)")
        case .Done:
            arrayOne.append("Completed Event: \(event.title)")
        }
        
        if event.isAllDay {
            arrayOne.append("All-Day Event")
        }
        
        let infoData = HLLEventInfoItemGenerator(event)
        let infoArray = infoData.getInfoItems(for: [.completion, .location, .period, .start, .end, .elapsed, .duration, .teacher, .calendar])
        
        for item in arrayOne {
            let menuItem = NSMenuItem()
            menuItem.title = item
            menu.addItem(menuItem)
        }
        
        
        menu.addItem(NSMenuItem.separator())
        
        for item in infoArray {
            let menuItem = NSMenuItem()
            menuItem.title = item.combined()
            menu.addItem(menuItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        if let nextOccur = FollowingOccurenceStore.shared.nextOccurDictionary[event.identifier], let title = infoData.getInfoItem(for: .nextOccurence)?.combined(), !hideNextOccur {
            
            menu.addItem(NSMenuItem.separator())
            
            let nextOccurMenuItem = NSMenuItem()
            nextOccurMenuItem.title = title
            nextOccurMenuItem.submenu = generateInfoSubmenuFor(event: nextOccur, hideNextOccur: true)
            menu.addItem(nextOccurMenuItem)
        }

        menu.addItem(NSMenuItem.separator())
        
        if HLLMain.proUser {
        
            let eventUIWindowButton = NSMenuItem()
            eventUIWindowButton.title = "Open Countdown Window..."
            eventUIWindowButton.target = EventUIWindowsManager.shared
            eventUIWindowButton.action = #selector(EventUIWindowsManager.shared.eventUIButtonClicked(sender:))
            DispatchQueue.main.async {
            EventUIWindowsManager.shared.addItemWithEvent(item: eventUIWindowButton, event: event)
            }
            menu.addItem(eventUIWindowButton)
        
        }
            
        if SelectedEventManager.selectedEvent == event {
            
            let eventUIWindowButton = NSMenuItem()
            eventUIWindowButton.title = "Clear Selection"
            eventUIWindowButton.target = SelectedEventManager.shared
            eventUIWindowButton.action = #selector(SelectedEventManager.shared.clearSelected)
            menu.addItem(eventUIWindowButton)
            
        }
        
      if let visString = event.visibilityString {
            
            let eventUIWindowButton = NSMenuItem()
            eventUIWindowButton.title = visString.rawValue
            eventUIWindowButton.target = EventVisibilityButtonsManager.shared
            eventUIWindowButton.action = #selector(EventVisibilityButtonsManager.shared.visibilityButtonClicked(sender:))
            menu.addItem(eventUIWindowButton)
            
        }
        
            
        
        return menu
        
        
    }
    
    
}
