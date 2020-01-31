//
//  MenuTopShelfGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class MenuTopShelfGenerator {
    
    let eventItemGen = EventMenuItemGenerator()
    let submenuGen = DetailSubmenuGenerator()
    let upcomingSectionGen = UpcomingSoonMenuGenerator()
    let upcomingWeekGen = UpcomingWeekMenuGenerator()
    var schoolEventChangesMenuItemGenerator: SchoolEventChangesMenuItemGenerator!
    
    func generateTopShelfMenuItems(currentEvents: [HLLEvent], upcomingEventsToday: [HLLEvent], moreUpcoming: [DateOfEvents]) -> [NSMenuItem] {
        
        schoolEventChangesMenuItemGenerator = SchoolEventChangesMenuItemGenerator(events: upcomingEventsToday)
        
        var items = [NSMenuItem]()
        
       
        
        let upcomingWillBeShown = HLLDefaults.menu.listUpcoming == true && HLLDefaults.menu.topLevelUpcoming == true
        
        let topLevelUpcoming = upcomingWillBeShown
        
        EventUIWindowsManager.shared.removeItems()
        SelectionMenuItemHandler.shared.removeItems()
        
        if let selected = SelectedEventManager.shared.selectedEvent {
          
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
        
        if HLLDefaults.general.showUpcomingWeekMenu, moreUpcoming.isEmpty == false {
        
        items.append(NSMenuItem.separator())
        
        let moreUpcomingMenuItem = NSMenuItem()
        moreUpcomingMenuItem.title = "More Upcoming"
        moreUpcomingMenuItem.submenu = NSMenu()
        
        items.append(moreUpcomingMenuItem)
        
        DispatchQueue.global().async {
            
            let submenu = self.upcomingWeekGen.generateUpcomingWeekMenuItem(for: moreUpcoming)
            
            DispatchQueue.main.async {
                moreUpcomingMenuItem.submenu = submenu
            }
            
        }
        
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
        
        if HLLEventSource.shared.access == .Denied {
                   
            items.removeAll()
            let item = NSMenuItem()
            item.title = "How Long Left needs calendar access to show your events."
            items.append(item)
            let item2 = NSMenuItem()
            item2.title = "Fix in System Preferences..."
            
            item2.target = MenuItemClosureHandler.shared
            item2.action = #selector(MenuItemClosureHandler.shared.runClosureFor(sender:))
            item2.representedObject = {
                
                DispatchQueue.main.async {
                    
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                        NSWorkspace.shared.open(url)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NSWorkspace.shared.launchApplication("System Preferences")
                    }
                    
                }
                
                
            }
            
            items.append(item2)
                   
        }
        
        items.append(NSMenuItem.separator())
        
        let preferencesMenuItem = NSMenuItem()
        preferencesMenuItem.title = "Preferences..."
        preferencesMenuItem.target = PreferencesWindowManager.shared
        preferencesMenuItem.action = #selector(PreferencesWindowManager.shared.objcLaunchPreferences)
        items.append(preferencesMenuItem)
        
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        quitMenuItem.target = TerminationHandler.shared
        quitMenuItem.action = #selector(TerminationHandler.shared.terminateApp)
        items.append(quitMenuItem)
        
        if HLLDefaults.magdalene.showCompassButton, SchoolAnalyser.schoolMode == .Magdalene {
            
            items.append(NSMenuItem.separator())
            
            let compassMenuItem = NSMenuItem()
            compassMenuItem.title = "Open Compass..."
            compassMenuItem.target = CompassLaunchHandler.shared
            compassMenuItem.action = #selector(CompassLaunchHandler.shared.launchCompass)
            items.append(compassMenuItem)
            
        }
        
        if NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) {
            
            items.append(NSMenuItem.separator())
            let menuItem = NSMenuItem()
            menuItem.title = "How Long Left \(Version.currentVersion) (\(Version.buildVersion))"
            items.append(menuItem)
            
        }
        
        return items
        
    }
    
}
