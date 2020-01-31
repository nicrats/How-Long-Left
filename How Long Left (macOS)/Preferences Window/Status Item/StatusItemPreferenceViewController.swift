//
//  StatusItemPreferenceViewController.swift
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

final class StatusItemPreferenceViewController: NSViewController, PreferencePane {
	
	let preferencePaneIdentifier = PreferencePane.Identifier.statusItem
    var preferencePaneTitle: String = "Status Item"
	
    let toolbarItemIcon = NSImage(named: "MenuSI")!
    
    override var nibName: NSNib.Name? {
        return "StatusItemPreferencesView"
    }
    
	@IBOutlet weak var modeSegmented: NSSegmentedControl!
	@IBOutlet weak var statusItemPreviewText: NSTextField!
	@IBOutlet weak var moreOptionsTitle: NSTextField!
	@IBOutlet weak var includeCurrentButton: NSButton!
	@IBOutlet weak var includeUpcomingButton: NSButton!
	@IBOutlet weak var simpleButton: NSButton!
	
	@IBOutlet weak var includeTitle: NSTextField!
	@IBOutlet weak var modeRadio_Off: NSButton!
    @IBOutlet weak var modeRadio_Timer: NSButton!
    @IBOutlet weak var modeRadio_Minute: NSButton!
    
    @IBOutlet weak var showTitleCheckbox: NSButton!
    @IBOutlet weak var showLeftTextCheckbox: NSButton!
    @IBOutlet weak var showPercentageCheckbox: NSButton!
	@IBOutlet weak var showEndTimeCheckbox: NSButton!

    
    @IBOutlet weak var previewIcon: NSImageView!
    @IBOutlet weak var unitsMenu: NSPopUpButton!
	@IBOutlet weak var previewTypeSegment: NSSegmentedControl!
	
	var desArray = [NSTextField]()
	
    let shortUnitsMenuItemText = "Use short units (h, min)"
    let fullUnitsMenuItemText = "Use full units (hours, minutes)"
    
    let timerFullText = "Include seconds"
	let timerShortText = "Don't include seconds"
	
	var timer: Timer?

	var previewEvent: HLLEvent?
	
	override func viewWillAppear() {
        
		
        PreferencesWindowManager.shared.currentIdentifier = preferencePaneIdentifier
        
    }
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = CGSize(width: 764, height: 331)
		
		timer = Timer(timeInterval: 0.2, target: self, selector: #selector(generateStatusItemPreview), userInfo: nil, repeats: true)
			RunLoop.main.add(timer!, forMode: .common)
		
		
		desArray = [des1, des2, des3, des4, includeTitle, moreOptionsTitle]
		
		previewIcon.alphaValue = 1.0
		//	previewIcon.contentTintColo
		
		switch HLLDefaults.statusItem.mode {
			
		case .Off:
			modeSegmented.selectedSegment = 0
		case .Timer:
			modeSegmented.selectedSegment = 1
		case .Minute:
			modeSegmented.selectedSegment = 2
		}
		
		adaptForMode(HLLDefaults.statusItem.mode)
		
		var SITitleState = NSControl.StateValue.off
		if HLLDefaults.statusItem.showTitle == true { SITitleState = .on }
		showTitleCheckbox.state = SITitleState
		
		var SILeftState = NSControl.StateValue.off
		if HLLDefaults.statusItem.showLeftText == true { SILeftState = .on }
		showLeftTextCheckbox.state = SILeftState
		
		var SICurrentsState = NSControl.StateValue.off
		if HLLDefaults.statusItem.showCurrent == true { SICurrentsState = .on }
		includeCurrentButton.state = SICurrentsState
		
		var SIUpcomingState = NSControl.StateValue.off
		if HLLDefaults.statusItem.showUpcoming == true { SIUpcomingState = .on }
		includeUpcomingButton.state = SIUpcomingState
		
		var image = NSImage(named: "logo")
		
		var SISimpleState = NSControl.StateValue.off
		if
			HLLDefaults.statusItem.appIconStatusItem == false { SISimpleState = .on
			
			image = NSImage(named: "MenuSI")
			
		}
		simpleButton.state = SISimpleState
		previewIcon.image = image
		
		
		var SIPercentageState = NSControl.StateValue.off
		if HLLDefaults.statusItem.showPercentage == true { SIPercentageState = .on }
		showPercentageCheckbox.state = SIPercentageState
		
		var SIEndState = NSControl.StateValue.off
		if HLLDefaults.statusItem.showEndTime == true { SIEndState = .on }
		showEndTimeCheckbox.state = SIEndState
		
		// Setup stuff here
		
		previewEvent = createPreviewEvent()
		
		statusItemPreviewText.font = NSFont.monospacedDigitSystemFont(ofSize: statusItemPreviewText.font!.pointSize, weight: .medium)
		
		self.generateStatusItemPreview()
		
	}
	
	func createPreviewEvent() -> HLLEvent {
		
		if previewTypeSegment.selectedSegment == 0 {
		
		return HLLEvent(title: "Event", start: Date().addingTimeInterval(-1), end: Date().addingTimeInterval(5400), location: nil)
			
		} else {
			
			return HLLEvent(title: "Event", start: Date().addingTimeInterval(5400), end: Date().addingTimeInterval(5460), location: nil)
			
		}
		
	}
	
	
	@IBAction func eventPreviewTypeSegementChanged(_ sender: NSSegmentedControl) {
		
		previewEvent = nil
		generateStatusItemPreview()
		
		
	}
	
	
	
    @IBAction func modeSegmentChanged(_ sender: NSSegmentedControl) {
		
		DispatchQueue.main.async {
			
			var value = 0
			
			if sender.selectedSegment == 0 {
				
				value = 2
				
			}
			
			if sender.selectedSegment == 1 {
				
				value = 0
				
			}
			
			if sender.selectedSegment == 2 {
				
				value = 1
				
			}
			
			
			
		
        if let mode = StatusItemMode(rawValue: value) {
            
            HLLDefaults.statusItem.mode = mode
			
			self.adaptForMode(mode)
        
			self.generateStatusItemPreview()
			
		}
        
    }
		
	}
	
	@IBAction func includeCurrentClicked(_ sender: NSButton) {
		
		DispatchQueue.main.async {
			
			var state = false
			if sender.state == .on { state = true }
			HLLDefaults.statusItem.showCurrent = state
			
			self.generateStatusItemPreview()
			
		}
		
	}
	
	@IBAction func includeUpcomingClicked(_ sender: NSButton) {
		
		DispatchQueue.main.async {
			
			var state = false
			if sender.state == .on { state = true }
			HLLDefaults.statusItem.showUpcoming = state
			
			self.generateStatusItemPreview()
			
		}
		
		
	}
	
	@IBAction func imageButtonClicked(_ sender: NSButton) {
		
		DispatchQueue.main.async {
			
			var image = NSImage(named: "logo")
			
			var state = false
			if sender.state == .on { state = true
				
				image = NSImage(named: "MenuSI")
				
			}
			
			self.previewIcon.image = image
			
			HLLDefaults.statusItem.appIconStatusItem = !state

			
			
			
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
    
	@IBAction func showEndTimeClicked(_ sender: NSButton) {
		
		DispatchQueue.main.async {
			
			var state = false
			if sender.state == .on { state = true }
			HLLDefaults.statusItem.showEndTime = state
			
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
			
		case self.shortUnitsMenuItemText:
			HLLDefaults.statusItem.useFullUnits = false
		
		case self.timerShortText:
			HLLDefaults.statusItem.hideTimerSeconds = true
			
		case self.timerFullText:
			HLLDefaults.statusItem.hideTimerSeconds = false
			
        default:
			break
			
        }
        
			self.generateStatusItemPreview()
			
		}
        
    }

	func adaptForMode(_ mode: StatusItemMode) {
		
		let isOff = mode != .Off
		
		var colour = NSColor.controlTextColor
		
		if mode == .Off {
			colour = NSColor.disabledControlTextColor
		}
		
		for item in desArray {
			item.textColor = colour
		}
	
		includeUpcomingButton.isEnabled = isOff
		includeCurrentButton.isEnabled = isOff
		showTitleCheckbox.isEnabled = isOff
		showEndTimeCheckbox.isEnabled = isOff
		showLeftTextCheckbox.isEnabled = isOff
		showPercentageCheckbox.isEnabled = isOff
		
		updateUnitsMenu(enabled: HLLDefaults.statusItem.mode == .Minute)
		
		
		
	}
	
    func updateUnitsMenu(enabled: Bool) {
		
		unitsMenu.removeAllItems()
		
		if HLLDefaults.statusItem.mode == .Off {
			
			unitsLabel.textColor = NSColor.disabledControlTextColor
			unitsMenu.isEnabled = false
			
			
		} else {
		
			unitsLabel.textColor = NSColor.controlTextColor
			unitsMenu.isEnabled = true
			
        if enabled == true {
			
            unitsMenu.addItems(withTitles: [shortUnitsMenuItemText,fullUnitsMenuItemText])
            
            if HLLDefaults.statusItem.useFullUnits == true {
                unitsMenu.selectItem(withTitle: fullUnitsMenuItemText)
            } else {
                unitsMenu.selectItem(withTitle: shortUnitsMenuItemText)
            }
            
        } else {
			
			unitsMenu.addItems(withTitles: [timerFullText, timerShortText])
			
			if HLLDefaults.statusItem.hideTimerSeconds == true {
				unitsMenu.selectItem(withTitle: timerShortText)
			} else {
				unitsMenu.selectItem(withTitle: timerFullText)
			}
            
        }
		
		
		}
        
    }
    
	@IBOutlet weak var unitsLabel: NSTextField!
	
	@IBOutlet weak var des1: NSTextField!
	@IBOutlet weak var des2: NSTextField!
	@IBOutlet weak var des3: NSTextField!
    @IBOutlet weak var des4: NSTextField!
	
	
	@objc func generateStatusItemPreview() {
		
		if previewEvent == nil {
			
			previewEvent = createPreviewEvent()
			
		}
		
		if let status = previewEvent?.completionStatus {
		
			if previewTypeSegment.selectedSegment == 0, status != .Current {
			
			previewEvent = createPreviewEvent()
			
		} else if previewTypeSegment.selectedSegment == 1, status != .Upcoming {
			
			previewEvent = createPreviewEvent()
			
			}

		
		}
		
		if let preview = previewEvent {
			
        
        switch HLLDefaults.statusItem.mode {
            
        case .Off:
            
			self.statusItemPreviewText.isHidden = true
			self.previewIcon.isHidden = false
            
        case .Timer:
            
			self.statusItemPreviewText.isHidden = false
			self.previewIcon.isHidden = true
            
            let stringGenerator = CountdownStringGenerator()
			let data = stringGenerator.generateStatusItemString(event: preview, mode: HLLDefaults.statusItem.mode)
			
			self.statusItemPreviewText.stringValue = data!
            
        case .Minute:
            
			self.statusItemPreviewText.isHidden = false
			self.previewIcon.isHidden = true
            
            let stringGenerator = CountdownStringGenerator()
			
			
			self.statusItemPreviewText.stringValue = stringGenerator.generateStatusItemMinuteModeString(event: preview)
            
        }
			
			
			
		}
			
		
	}
	
    
    
}
