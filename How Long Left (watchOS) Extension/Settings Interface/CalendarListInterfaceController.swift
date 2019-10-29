//
//  CalendarListInterfaceController.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 29/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import WatchKit
import Foundation
import EventKit

class CalendarListInterfaceController: WKInterfaceController, DefaultsTransferObserver, SwitchListController {

    @IBOutlet weak var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        HLLDefaultsTransfer.shared.addTransferObserver(self)
        setup()
        // Configure interface objects here.
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
    }
    
    func setup() {
        
        let calendars = HLLEventSource.shared.getCalendars()
        
        table.setNumberOfRows(calendars.count, withRowType: "CalendarRow")
        
        for (index, calendar) in calendars.enumerated() {
            
            let row = table.rowController(at: index) as! CalendarRow
            row.setup(calendar, delegate: self)
            
        }
        
        setupMenuItem()
        
    }
    
    func setupMenuItem() {
        
        self.clearAllMenuItems()
        
        let allCalendarIDS = HLLEventSource.shared.getCalendarIDS()
        let enabledCalendarIDS = HLLDefaults.calendar.enabledCalendars
        
        if allCalendarIDS == enabledCalendarIDS {
            self.addMenuItem(with: UIImage(), title: "Deselect All", action: #selector(toggleAll))
        } else {
            self.addMenuItem(with: UIImage(), title: "Select All", action: #selector(toggleAll))
        }
        
    }
    
    @objc func toggleAll() {
        
        let allCalendarIDS = HLLEventSource.shared.getCalendarIDS()
        let enabledCalendarIDS = HLLDefaults.calendar.enabledCalendars
        
        if allCalendarIDS == enabledCalendarIDS {
            
            HLLDefaults.calendar.enabledCalendars.removeAll()
            HLLDefaults.calendar.disabledCalendars = allCalendarIDS
            
        } else {
            
            HLLDefaults.calendar.enabledCalendars = allCalendarIDS
            HLLDefaults.calendar.disabledCalendars.removeAll()
            
        }
        
        setup()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func defaultsUpdatedRemotely() {
        DispatchQueue.main.async {
            self.setup()
        }
    }
    
    func switchWasToggled() {
        
        setupMenuItem()
        
    }

}

class CalendarRow: NSObject {
    
    @IBOutlet weak var rowSwitch: WKInterfaceSwitch!
    
    var calendar: EKCalendar!
    var delegate: SwitchListController!
    
    func setup(_ calendar: EKCalendar, delegate: SwitchListController) {
        
        self.delegate = delegate
        self.calendar = calendar
        rowSwitch.setTitle(calendar.title)
        
        let on = HLLDefaults.calendar.enabledCalendars.contains(calendar.calendarIdentifier)
        rowSwitch.setOn(on)
        
    }
    
    @IBAction func toggled(_ value: Bool) {
        
        DispatchQueue.global(qos: .default).async {
        
        if value == true {
            
            if !HLLDefaults.calendar.enabledCalendars.contains(self.calendar.calendarIdentifier) {
                
                var old = HLLDefaults.calendar.enabledCalendars
                old.append(self.calendar.calendarIdentifier)
                
                HLLDefaults.calendar.enabledCalendars = old
                
            }
            
            if HLLDefaults.calendar.disabledCalendars.contains(self.calendar.calendarIdentifier) {
                
                var old = HLLDefaults.calendar.disabledCalendars
                old.removeAll { $0 == self.calendar.calendarIdentifier }
                
                HLLDefaults.calendar.disabledCalendars = old
                
            }
            
        } else {
            
            
            if !HLLDefaults.calendar.disabledCalendars.contains(self.calendar.calendarIdentifier) {
                
                var old = HLLDefaults.calendar.disabledCalendars
                old.append(self.calendar.calendarIdentifier)
                HLLDefaults.calendar.disabledCalendars = old
                
            }
            
            if HLLDefaults.calendar.enabledCalendars.contains(self.calendar.calendarIdentifier) {
                
                var old = HLLDefaults.calendar.enabledCalendars
                if let index = old.firstIndex(where: { $0 == self.calendar.calendarIdentifier }) {
                    old.remove(at: index)
                }
                
                HLLDefaults.calendar.enabledCalendars = old
                
            }
            
        }
        
        print("Toggled")

        HLLDefaultsTransfer.shared.userModifiedPrferences()
            
        self.delegate.switchWasToggled()
            
        }
        
    }
}

protocol SwitchListController {
    
    func switchWasToggled()
    
}
