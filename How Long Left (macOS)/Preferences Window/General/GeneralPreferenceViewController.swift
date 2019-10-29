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

final class GeneralPreferenceViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    override var nibName: NSNib.Name? {
        return "GeneralPreferencesView"
    }
    
    @IBOutlet weak var launchAtLoginCheckbox: NSButton!
    @IBOutlet weak var showPercentageCheckbox: NSButton!
    @IBOutlet weak var showLocationsCheckbox: NSButton!
    @IBOutlet weak var use24HourTime: NSButton!
    @IBOutlet weak var allDayCheckbox: NSButton!
    @IBOutlet weak var allDayCurrentButton: NSPopUpButton!
    
    var allDayExcludeText = "Require selection to appear in status item"
    var allDayIncludeText = "Automatically include in status item"
    
    @IBAction func launchAtLoginClicked(_ sender: NSButton) {
        
        var state = false
        if sender.state == .on { state = true }
        LaunchAtLogin.isEnabled = state
        
    }
    
    
    @IBAction func showPercentageClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.general.showPercentage = state
            
        }
        
    }
    
    @IBAction func showAllDayClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.general.showAllDay = state
            self.allDayCurrentButton.isEnabled = state
            
        
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
            
        }
        
    }
    
    @IBAction func allDayPopupClicked(_ sender: NSPopUpButton) {
        
        DispatchQueue.main.async {
        
            if sender.selectedItem?.title == self.allDayIncludeText {
            
            HLLDefaults.general.showAllDayInStatusItem = true
            
        } else {
            
            HLLDefaults.general.showAllDayInStatusItem = false
        }
        
        
            
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
            
        }
            
        
    }
    
    
    
    @IBAction func use24HourTimeClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
            
            var state = false
            if sender.state == .on { state = true }
            HLLDefaults.general.use24HourTime = state
            
            HLLDefaults.defaults.set(true, forKey: "changed24HourPref")
            
        }
        
        
    }
    @IBAction func showLocationsClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
        
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.general.showLocation = state
            
        
        
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allDayCurrentButton.removeAllItems()
        
        allDayCurrentButton.addItems(withTitles: [allDayExcludeText, allDayIncludeText])
        
        if HLLDefaults.general.showAllDayInStatusItem == true {
            
            allDayCurrentButton.selectItem(withTitle: allDayIncludeText)
            
        } else {
            
            allDayCurrentButton.selectItem(withTitle: allDayExcludeText)
            
        }
        
        
        if LaunchAtLogin.isEnabled == true {
            launchAtLoginCheckbox.state = .on
        } else {
            launchAtLoginCheckbox.state = .off
        }
        
        if HLLDefaults.general.showPercentage == true {
            showPercentageCheckbox.state = .on
        } else {
            showPercentageCheckbox.state = .off
        }
        
        
        if HLLDefaults.general.showAllDay == true {
            allDayCheckbox.state = .on
            allDayCurrentButton.isEnabled = true
        } else {
            allDayCheckbox.state = .off
            allDayCurrentButton.isEnabled = false
        }
        
        if HLLDefaults.general.showLocation == true {
            showLocationsCheckbox.state = .on
        } else {
            showLocationsCheckbox.state = .off
        }
        
        if HLLDefaults.general.use24HourTime == true {
            use24HourTime.state = .on
        } else {
            use24HourTime.state = .off
        }
        
        // Setup stuff here
    }
    
}
