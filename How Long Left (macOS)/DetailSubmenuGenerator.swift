//
//  DetailSubmenuGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 8/3/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class DetailSubmenuGenerator {
    
    var countdownStringGen = CountdownStringGenerator()
    
    func generateInfoSubmenuFor(event: HLLEvent, isFollowingOccurence: Bool = false, isWithinFollowingOccurenceSubmenu: Bool = false ) -> NSMenu {

        let menu = NSMenu()
        
        var arrayOne = [String]()
        
        let title = event.title.truncated(limit: 30, position: .middle, leader: "...")
        
        switch event.completionStatus {
            
        case .Upcoming:
    
        let startsInText = countdownStringGen.generateCountdownTextFor(event: event).justCountdown
        arrayOne.append("\(title) - In \(startsInText)")
            
        case .Current:
            arrayOne.append("On Now: \(title)")
        case .Done:
            arrayOne.append("Completed Event: \(title)")
        }
        
        if event.isAllDay {
            arrayOne.append("All-Day Event")
        }
        
        let infoData = HLLEventInfoItemGenerator(event)
        let infoArray = infoData.getInfoItems(for: [.completion, .location, .oldLocationName, .period, .start, .end, .elapsed, .duration, .teacher])
        
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
        
        if HLLDefaults.general.showNextOccurItems, isWithinFollowingOccurenceSubmenu == false {
        
        var currentEvent: HLLEvent? = event
        var followingOccurences = [HLLEvent]()
        
        while currentEvent != nil {
            

            
            if let next = currentEvent?.followingOccurence {
            
                followingOccurences.append(next)
                currentEvent = next
                
            } else {
                currentEvent = nil
            }
            
        }
            
        if followingOccurences.isEmpty == false {
        
            if followingOccurences.count > 1, isFollowingOccurence, HLLDefaults.general.useNextOccurList  {
        
            let firstEvent = followingOccurences.first!
                
            menu.addItem(NSMenuItem.separator())
            
            let moreFollowingOccurencesMenuItem = NSMenuItem()
            moreFollowingOccurencesMenuItem.title = "More Following Occurences"
            
            let moreFollowingOccurencesSubmenu = NSMenu()
            
            let topMenuItem = NSMenuItem()
            topMenuItem.title = "Following Occurences: \(firstEvent.title)"
            
            moreFollowingOccurencesSubmenu.addItem(topMenuItem)
            moreFollowingOccurencesSubmenu.addItem(NSMenuItem.separator())
                
            for nextOccurEvent in followingOccurences {
                    
                var text = nextOccurEvent.startDate.userFriendlyRelativeString()
                    
                if let period = nextOccurEvent.period {
                    text += ", Period \(period)"
                }
                
                let moreFollowingOccurencesSubmenuItem = NSMenuItem()
                moreFollowingOccurencesSubmenuItem.title = text
                
                moreFollowingOccurencesSubmenuItem.submenu = generateInfoSubmenuFor(event: nextOccurEvent, isFollowingOccurence: true, isWithinFollowingOccurenceSubmenu: true)
                moreFollowingOccurencesSubmenuItem.action = #selector(SelectionMenuItemHandler.shared.selectEventFromMenuItem(sender:))
                moreFollowingOccurencesSubmenuItem.target = SelectionMenuItemHandler.shared
                SelectionMenuItemHandler.shared.addItemWithEvent(item: moreFollowingOccurencesSubmenuItem, event: nextOccurEvent)
                
                if nextOccurEvent.isSelected {
                    moreFollowingOccurencesSubmenuItem.state = .on
                }
                
                moreFollowingOccurencesSubmenu.addItem(moreFollowingOccurencesSubmenuItem)
                
                }
                
                
                moreFollowingOccurencesMenuItem.submenu = moreFollowingOccurencesSubmenu
                 menu.addItem(moreFollowingOccurencesMenuItem)
                    
            
        } else {
            
            if let nextOccur = FollowingOccurenceStore.shared.nextOccurDictionary[event.identifier], let title = infoData.getInfoItem(for: .nextOccurence)?.combined() {
                
                menu.addItem(NSMenuItem.separator())
                
                let nextOccurMenuItem = NSMenuItem()
                nextOccurMenuItem.title = title
                nextOccurMenuItem.submenu = generateInfoSubmenuFor(event: nextOccur, isFollowingOccurence: true)
                
                nextOccurMenuItem.action = #selector(SelectionMenuItemHandler.shared.selectEventFromMenuItem(sender:))
                nextOccurMenuItem.target = SelectionMenuItemHandler.shared
                SelectionMenuItemHandler.shared.addItemWithEvent(item: nextOccurMenuItem, event: nextOccur)
                
                if nextOccur.isSelected {
                    nextOccurMenuItem.state = .on
                }
                
                menu.addItem(nextOccurMenuItem)
            }

        }
                
           
            }
        }

        menu.addItem(NSMenuItem.separator())
        
        var actionItems = [NSMenuItem]()
        
            let eventUIWindowButton = NSMenuItem()
            eventUIWindowButton.title = "Open Countdown Window..."
            eventUIWindowButton.target = EventUIWindowsManager.shared
            eventUIWindowButton.action = #selector(EventUIWindowsManager.shared.eventUIButtonClicked(sender:))
            DispatchQueue.main.async {
            EventUIWindowsManager.shared.addItemWithEvent(item: eventUIWindowButton, event: event)
            }
            actionItems.append(eventUIWindowButton)
        
        
        if SelectedEventManager.shared.selectedEvent == event {
            
            let clearSelectionButton = NSMenuItem()
            clearSelectionButton.title = "Clear Selection"
            clearSelectionButton.target = SelectionMenuItemHandler.shared
            clearSelectionButton.action = #selector(SelectionMenuItemHandler.shared.clearSelected)
            actionItems.append(clearSelectionButton)
            
        }
        
        if event.isSchoolEvent, event.location != nil, HLLDefaults.magdalene.oldRoomNames == .showInSubmenu {
            
            let useOldButton = NSMenuItem()
            useOldButton.title = "Use Old Room Names Everywhere"
            useOldButton.target = MenuItemClosureHandler.shared
            useOldButton.action = #selector(MenuItemClosureHandler.shared.runClosureFor(sender:))
            useOldButton.representedObject = {
                
                HLLDefaults.magdalene.oldRoomNames = .replace
                HLLEventSource.shared.asyncUpdateEventPool()
                
            }
            actionItems.append(useOldButton)
            
        }
        
        if event.isAllDay {
            
            let hideAllDayEventsButton = NSMenuItem()
            hideAllDayEventsButton.title = "Hide All-Day Events"
            hideAllDayEventsButton.target = MenuItemClosureHandler.shared
            hideAllDayEventsButton.action = #selector(MenuItemClosureHandler.shared.runClosureFor(sender:))
            hideAllDayEventsButton.representedObject = {
                
                HLLDefaults.general.showAllDay = false
                HLLEventSource.shared.asyncUpdateEventPool()
                
            }
            actionItems.append(hideAllDayEventsButton)
            
        }
        
        if let calendar = event.calendar {
            
            let calendarButton = NSMenuItem()
            calendarButton.title = "Disable \"\(calendar.title)\""
            calendarButton.representedObject = calendar
            calendarButton.target = HideCalendarMenuItemHandler.shared
            calendarButton.action = #selector(HideCalendarMenuItemHandler.shared.hideCalendarFor(sender:))
            actionItems.append(calendarButton)
            
        }

      /*  if let location = event.location, EventLocationIndexer.shared.index[location] != nil {
            
            let locationButton = NSMenuItem()
            locationButton.title = "Show Location In Maps..."
            locationButton.representedObject = event
            locationButton.target = MapMenuItemHandler.shared
            locationButton.action = #selector(MapMenuItemHandler.shared.openMapsFor(sender:))
            actionItems.append(locationButton)
            
            
        } */
        
      if let visString = event.visibilityString {
            
            let visibilityButton = NSMenuItem()
            visibilityButton.title = visString.rawValue
            visibilityButton.target = EventVisibilityButtonsManager.shared
            visibilityButton.action = #selector(EventVisibilityButtonsManager.shared.visibilityButtonClicked(sender:))
            actionItems.append(visibilityButton)
            
        }
        
        if event.followingOccurence != nil, HLLDefaults.general.showNextOccurItems == true, isFollowingOccurence == false {
            
            let hideNextOccurButton = NSMenuItem()
            hideNextOccurButton.title = "Hide Following Occurences"
            hideNextOccurButton.target = MenuItemClosureHandler.shared
            hideNextOccurButton.action = #selector(MenuItemClosureHandler.shared.runClosureFor(sender:))
            hideNextOccurButton.representedObject = {
                           
                HLLDefaults.general.showNextOccurItems = false
                HLLEventSource.shared.asyncUpdateEventPool()
                           
            }
            actionItems.append(hideNextOccurButton)
            
            
        }
        
        if event.period == "S", HLLDefaults.magdalene.showSportAsStudy == false {
            
            let hideNextOccurButton = NSMenuItem()
            hideNextOccurButton.title = "Show Sport As Study"
            hideNextOccurButton.target = MenuItemClosureHandler.shared
            hideNextOccurButton.action = #selector(MenuItemClosureHandler.shared.runClosureFor(sender:))
            hideNextOccurButton.representedObject = {
                                      
                HLLDefaults.magdalene.showSportAsStudy.toggle()
                HLLEventSource.shared.asyncUpdateEventPool()
                                      
            }
            actionItems.append(hideNextOccurButton)
                       
        }
        
        if actionItems.count > 2 {
            
            let firstItem = actionItems.removeFirst()
            menu.addItem(firstItem)

            let actionsSubmenu = NSMenu()
            
            for item in actionItems {
                
                actionsSubmenu.addItem(item)
                
            }
            
            let moreActionsMenuItem = NSMenuItem()
            moreActionsMenuItem.title = "More"
            moreActionsMenuItem.submenu = actionsSubmenu
            
            menu.addItem(moreActionsMenuItem)
            
            
        } else {
            
            for item in actionItems {
                
                menu.addItem(item)
            }
            
        }
            
        
        return menu
        
        
    }
    
    
}
