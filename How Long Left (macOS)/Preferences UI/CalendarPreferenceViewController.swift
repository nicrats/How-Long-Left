//
//  CalendarPreferenceViewController.swift
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

final class CalendarPreferenceViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "Calendar"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    let calendarData = EventDataSource.shared
    let schoolAnalyzer = SchoolAnalyser()
    var titleIdentifierDictionary: [String: String] = [:]
    var identifierTitleDictionary: [String: String] = [:]
    
    
    @IBOutlet weak var calendarSelectBox: NSPopUpButton!
    @IBOutlet weak var useAllButton: NSButton!
    
    override var nibName: NSNib.Name? {
        return "CalendarPreferencesView"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if HLLDefaults.calendar.useAllCalendars == true {
            
            useAllButton.state = .on
            
        } else {
            
            useAllButton.state = .off
            
        }
        
        updateUI()
        
        // Setup stuff here
    }
    
    @IBAction func calendarSelectBoxClicked(_ sender: NSPopUpButton) {
        
        DispatchQueue.main.async {
        
            if let ID = self.titleIdentifierDictionary[sender.title] {
            
            print("\(sender.title) = \(ID)")
            HLLDefaults.calendar.selectedCalendar = ID
        }
        
        
            self.updateUI()
            
        }
        
    }
    
    
    @IBAction func useAllClicked(_ sender: NSButton) {
        
        DispatchQueue.main.async {
        
        if self.useAllButton.state == .on {
            
            HLLDefaults.calendar.useAllCalendars = true
            self.calendarSelectBox.isEnabled = false
            
        } else {
            HLLDefaults.calendar.useAllCalendars = false
            self.calendarSelectBox.isEnabled = true
            
        }
            
            
            
        }
        
        DispatchQueue.main.async {
            self.updateUI()
        }
        
    }
    
    func updateUI() {
        
        
        if useAllButton.state == .on {
            
            HLLDefaults.calendar.useAllCalendars = true
            calendarSelectBox.isEnabled = false
            
        } else {
            HLLDefaults.calendar.useAllCalendars = false
            calendarSelectBox.isEnabled = true
            
        }
        
        calendarSelectBox.removeAllItems()
        titleIdentifierDictionary.removeAll()
        identifierTitleDictionary.removeAll()
        
        let cals = calendarData.getCalendars()
        
        for item in cals {
            
            calendarSelectBox.addItem(withTitle: item.title)
            titleIdentifierDictionary[item.title] = item.calendarIdentifier
            identifierTitleDictionary[item.calendarIdentifier] = item.title
            
        }
        
        if let selectedCalendar = HLLDefaults.calendar.selectedCalendar, let title = identifierTitleDictionary[selectedCalendar] {
            calendarSelectBox.selectItem(withTitle: title)
        }
        
        DispatchQueue.global(qos: .default).async {
        self.schoolAnalyzer.analyseCalendar()
        NotificationCenter.default.post(name: Notification.Name("updateCalendar"), object: nil)
        }
        
    }
    
}
