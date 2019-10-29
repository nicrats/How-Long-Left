//
//  DefaultsMigrator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 11/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class DefaultsMigrator {

    let defaults = HLLDefaults.defaults

    
    func migrate1XXDefaults() {
        
        if defaults.string(forKey: "setupComplete") != nil {
        
        if defaults.string(forKey: "showPercentageInStatusItem") == "1" {
            HLLDefaults.statusItem.showPercentage = true
        } else {
            HLLDefaults.statusItem.showPercentage = false
        }
        
        if defaults.string(forKey: "showPercentage") == "1" {
            HLLDefaults.general.showPercentage = true
        } else {
            HLLDefaults.general.showPercentage = false
        }
        
        if defaults.string(forKey: "showLocations") == "1" {
            HLLDefaults.general.showLocation = true
        } else {
            HLLDefaults.general.showLocation = false
        }
        
        if defaults.string(forKey: "showMyDay") == "1" {
            HLLDefaults.general.showUpcomingWeekMenu = true
        } else {
            HLLDefaults.general.showUpcomingWeekMenu = false
        }
        
      /*  if defaults.string(forKey: "showNext") == "1" {
            HLLDefaults.general.showNextEvent = true
        } else {
            HLLDefaults.general.showNextEvent = false
        } */
        
        var milestoneArray = [Int]()
        
        if defaults.string(forKey: "autoAlert10") == "1" {
            milestoneArray.append(600)
        }
        
        if defaults.string(forKey: "autoAlert5") == "1" {
            milestoneArray.append(300)
        }
        
        if defaults.string(forKey: "autoAlert1") == "1" {
            milestoneArray.append(60)
        }
        
        if defaults.string(forKey: "autoAlert0") == "1" {
            milestoneArray.append(0)
        }
        
        HLLDefaults.notifications.milestones = milestoneArray
        
        if let setKey = defaults.string(forKey: "setHotKey") {
            switch setKey {
            case "Off":
                HLLDefaults.notifications.hotkey = .Off
            case "Option + W":
                HLLDefaults.notifications.hotkey = .OptionW
            case "Command + T":
                HLLDefaults.notifications.hotkey = .CommandT
            default:
                break
            }
        
            }
            
            if let setCal = defaults.string(forKey: "Calendar") {
            
           HLLEventSource.shared.getCalendarAccess()
            let cals = HLLEventSource.shared.getCalendars()
            
            for calendar in cals {
                
                if calendar.title == setCal {
                    HLLDefaults.calendar.selectedCalendar = calendar.calendarIdentifier
                }
                
            }
            
            }
            
        }
    
    }
    

}
