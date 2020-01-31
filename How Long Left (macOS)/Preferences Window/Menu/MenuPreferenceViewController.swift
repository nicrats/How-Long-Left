//
//  GeneralPreferenceViewController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 4/12/18.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa
import Preferences
import LaunchAtLogin
import EventKit

final class MenuPreferenceViewController: NSViewController, PreferencePane {

    let preferencePaneIdentifier = PreferencePane.Identifier.menu
    var preferencePaneTitle: String = "Menu"
    
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    @IBOutlet weak var listUpcomingButton: NSButton!
    @IBOutlet weak var upcomingTypePopup: NSPopUpButton!
    @IBOutlet weak var showUpcomingWeekButton: NSButton!
    @IBOutlet weak var showNextOccurencesButton: NSButton!
    @IBOutlet weak var groupFollowingOccurencesButton: NSButton!
    @IBOutlet weak var groupFollowingOccurencesDescription: NSTextField!
    
    var listUpcomingOptionTopLevel = "In the top level menu"
    var listUpcomingOptionDedicated = "In a dedicated submenu"
    
    var submenuStoryboard: NSStoryboard!
    var submenuWindowController: NSWindowController!
    
    override var nibName: NSNib.Name? {
        return "MenuPreferencesView"
    }
    
    override func viewWillAppear() {
        
        PreferencesWindowManager.shared.currentIdentifier = preferencePaneIdentifier
        
    }
    
    override func viewDidLoad() {
        
        self.preferredContentSize = CGSize(width: 466, height: 222)
        
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
        
        if HLLDefaults.general.useNextOccurList == true {
            groupFollowingOccurencesButton.state = .on
        } else {
            groupFollowingOccurencesButton.state = .off
        }

        if HLLDefaults.general.showNextOccurItems == true {
            showNextOccurencesButton.state = .on
            groupFollowingOccurencesButton.isEnabled = true
            groupFollowingOccurencesDescription.isEnabled = true
        } else {
            showNextOccurencesButton.state = .off
            groupFollowingOccurencesButton.isEnabled = false
            groupFollowingOccurencesDescription.isEnabled = false
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
    
    @IBAction func eventSubmenuButtonClicked(_ sender: NSButton) {
        
        self.submenuStoryboard = NSStoryboard(name: "EventInfoSubmenuConfiguration", bundle: nil)
                           
        self.submenuWindowController = self.submenuStoryboard.instantiateController(withIdentifier: "SubmenuConfigWindow") as? NSWindowController
                           
        //self.welcomeWindowController!.window!.delegate = self
        submenuWindowController.window!.collectionBehavior = .canJoinAllSpaces
        submenuWindowController.window!.level = .floating
        self.submenuWindowController.showWindow(self)
        
    }
    
    @IBAction func groupNextOccurClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.general.useNextOccurList = state
            
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
            
            self.groupFollowingOccurencesButton.isEnabled = state
            self.groupFollowingOccurencesDescription.isEnabled = state
            
        }
        
    }
    
}
