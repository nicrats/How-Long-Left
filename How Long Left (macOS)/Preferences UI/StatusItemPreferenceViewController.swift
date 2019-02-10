//
//  StatusItemPreferenceViewController.swift
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

final class StatusItemPreferenceViewController: NSViewController, Preferenceable {
	
	let toolbarItemTitle = "Status Item"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    override var nibName: NSNib.Name? {
        return "StatusItemPreferencesView"
    }
    
    @IBOutlet weak var statusItemPreviewText: NSTextField!
    
    @IBOutlet weak var modeRadio_Off: NSButton!
    @IBOutlet weak var modeRadio_Timer: NSButton!
    @IBOutlet weak var modeRadio_Minute: NSButton!
    
    @IBOutlet weak var showTitleCheckbox: NSButton!
    @IBOutlet weak var showLeftTextCheckbox: NSButton!
    @IBOutlet weak var showPercentageCheckbox: NSButton!
    
    @IBOutlet weak var unitsMenu: NSPopUpButton!
    
    let shortUnitsMenuItemText = "Use short units (hr, min)"
    let fullUnitsMenuItemText = "Use full units (hours, minutes)"
    
    let unavalibleUnitsMenuItemText = "Only avaliable in Minute mode"
    
    @IBAction func modeRadioChanged(_ sender: NSButton) {
		
		DispatchQueue.main.async {
			
		
        if let mode = StatusItemMode(rawValue: Int(sender.identifier!.rawValue)!) {
            
            HLLDefaults.statusItem.mode = mode
            
            let isOff = mode != .Off
            
			self.showTitleCheckbox.isEnabled = isOff
			self.showLeftTextCheckbox.isEnabled = isOff
			self.showPercentageCheckbox.isEnabled = isOff
            
			self.updateUnitsMenu(enabled: mode == .Minute)
            
        }
        
			self.generateStatusItemPreview()
			
		}
        
    }
    
    @IBAction func showTitleClicked(_ sender: NSButton) {
		
		DispatchQueue.main.async {
		
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.statusItem.showTitle = state
        
			self.generateStatusItemPreview()
			
		}
        
    }
    
    @IBAction func showLeftText(_ sender: NSButton) {
		
		DispatchQueue.main.async {
		
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.statusItem.showLeftText = state
        
			self.generateStatusItemPreview()
			
		}
        
    }
    
    
    @IBAction func showPercentageClicked(_ sender: NSButton) {
		
		DispatchQueue.main.async {
		
        var state = false
        if sender.state == .on { state = true }
        HLLDefaults.statusItem.showPercentage = state
        
			self.generateStatusItemPreview()
			
		}
        
    }
    
    @IBAction func unitsClicked(_ sender: NSPopUpButton) {
		
		DispatchQueue.main.async {
		
        switch sender.selectedItem!.title {
            
		case self.fullUnitsMenuItemText:
            HLLDefaults.statusItem.useFullUnits = true
        default:
            HLLDefaults.statusItem.useFullUnits = false
            
        }
        
			self.generateStatusItemPreview()
			
		}
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch HLLDefaults.statusItem.mode {
            
        case .Off:
            modeRadio_Off.state = NSControl.StateValue.on
        case .Timer:
            modeRadio_Timer.state = NSControl.StateValue.on
        case .Minute:
            modeRadio_Minute.state = NSControl.StateValue.on
            
        }
        
        var SITitleState = NSControl.StateValue.off
        if HLLDefaults.statusItem.showTitle == true { SITitleState = .on }
        showTitleCheckbox.state = SITitleState
        
        var SILeftState = NSControl.StateValue.off
        if HLLDefaults.statusItem.showLeftText == true { SILeftState = .on }
        showLeftTextCheckbox.state = SILeftState
        
        var SIPercentageState = NSControl.StateValue.off
        if HLLDefaults.statusItem.showPercentage == true { SIPercentageState = .on }
        showPercentageCheckbox.state = SIPercentageState
        
        let mode = HLLDefaults.statusItem.mode
        let isOff = mode != .Off
        showTitleCheckbox.isEnabled = isOff
        showLeftTextCheckbox.isEnabled = isOff
        showPercentageCheckbox.isEnabled = isOff
        
        updateUnitsMenu(enabled: HLLDefaults.statusItem.mode == .Minute)
        
        generateStatusItemPreview()
        
        // Setup stuff here
    }
    
    func updateUnitsMenu(enabled: Bool) {
        
        if enabled == true {
            
            unitsMenu.isEnabled = true
            unitsMenu.removeAllItems()
            unitsMenu.addItems(withTitles: [shortUnitsMenuItemText,fullUnitsMenuItemText])
            
            if HLLDefaults.statusItem.useFullUnits == true {
                unitsMenu.selectItem(withTitle: fullUnitsMenuItemText)
            } else {
                unitsMenu.selectItem(withTitle: shortUnitsMenuItemText)
            }
            
        } else {
            
            unitsMenu.isEnabled = false
            unitsMenu.removeAllItems()
            unitsMenu.addItem(withTitle: unavalibleUnitsMenuItemText)
            
        }
        
    }
    
    func generateStatusItemPreview() {
        
        let previewEvent = HLLEvent(title: "Event", start: Date().addingTimeInterval(-5400), end: Date().addingTimeInterval(5400), location: nil)
        
        switch HLLDefaults.statusItem.mode {
            
        case .Off:
            
            statusItemPreviewText.stringValue = "Off"
            
        case .Timer:
            
            let stringGenerator = StatusItemTimerStringGenerator(isForPreview: true)
            let data = stringGenerator.generateStringsFor(event: previewEvent)
            let key = data.keys.first!
            statusItemPreviewText.stringValue = data[key]!
            
        case .Minute:
            
            let stringGenerator = CountdownStringGenerator()
            statusItemPreviewText.stringValue = stringGenerator.generateStatusItemString(event: previewEvent)!
            
        }
        
        
    }
    
    
}
