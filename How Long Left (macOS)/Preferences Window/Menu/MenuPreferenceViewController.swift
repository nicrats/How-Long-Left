//
//  GeneralPreferenceViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Preferences
import LaunchAtLogin
import EventKit

final class MenuPreferenceViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "Menu"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    @IBOutlet weak var listUpcomingButton: NSButton!
    @IBOutlet weak var upcomingTypePopup: NSPopUpButton!
    @IBOutlet weak var showUpcomingWeekButton: NSButton!
    @IBOutlet weak var showNextOccurencesButton: NSButton!
    
    var listUpcomingOptionTopLevel = "In the top level menu"
    var listUpcomingOptionDedicated = "In a dedicated submenu"
    
    override var nibName: NSNib.Name? {
        return "MenuPreferencesView"
    }
    
    override func viewDidLoad() {
        
        if HLLDefaults.menu.listUpcoming == true {
            listUpcomingButton.state = .on
            upcomingTypePopup.isEnabled = true
        } else {
            listUpcomingButton.state = .off
            upcomingTypePopup.isEnabled = false
        }
        
        upcomingTypePopup.removeAllItems()
        
        upcomingTypePopup.addItems(withTitles: [listUpcomingOptionDedicated, listUpcomingOptionTopLevel])
        
        if HLLDefaults.menu.topLevelUpcoming == true {
            upcomingTypePopup.selectItem(withTitle: listUpcomingOptionTopLevel)
        } else {
            upcomingTypePopup.selectItem(withTitle: listUpcomingOptionDedicated)
        }
        
        if HLLDefaults.general.showUpcomingWeekMenu == true {
            showUpcomingWeekButton.state = .on
        } else {
            showUpcomingWeekButton.state = .off
        }

        if HLLDefaults.general.showNextOccurItems == true {
            showNextOccurencesButton.state = .on
        } else {
            showNextOccurencesButton.state = .off
        }

        
    }
    
    @IBAction func listUpcomingClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.menu.listUpcoming = state
            self.upcomingTypePopup.isEnabled = state
            
        }
        
    }
    
    
    
    @IBAction func listUpcomingPopupClicked(_ sender: NSPopUpButton) {
        
        if sender.selectedItem?.title == listUpcomingOptionTopLevel {
            
            HLLDefaults.menu.topLevelUpcoming = true
            
        } else {
            
            HLLDefaults.menu.topLevelUpcoming = false
        }
        
    }
    
    @IBAction func showUpcomingWeekClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.general.showUpcomingWeekMenu = state
            
        }
    }
    
    @IBAction func showNextOccurencesClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.general.showNextOccurItems = state
            
            NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
            
        }
        
    }
    
}
