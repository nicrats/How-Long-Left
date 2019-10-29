//
//  CalendarDefaultsModifier.swift
//  How Long Left
//
//  Created by Ryan Kontos on 21/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

class CalendarDefaultsModifier {
    
    static var shared = CalendarDefaultsModifier()
    
    func setEnabled(calendar: EKCalendar) {
        setEnabledWith(identifier: calendar.calendarIdentifier)
    }
    
    func setDisabled(calendar: EKCalendar) {
        setDisabledWith(identifier: calendar.calendarIdentifier)
    }
    
    func toggle(calendar: EKCalendar) {
        toggleWith(identifier: calendar.calendarIdentifier)
    }
    
    func setEnabledWith(identifier: String) {
        
        if !HLLDefaults.calendar.enabledCalendars.contains(identifier) {
            HLLDefaults.calendar.enabledCalendars.append(identifier)
        }
             
        if let index = HLLDefaults.calendar.disabledCalendars.firstIndex(of: identifier) {
            HLLDefaults.calendar.disabledCalendars.remove(at: index)
        }
             
    }
    
    func setDisabledWith(identifier: String) {
        
        if let index = HLLDefaults.calendar.enabledCalendars.firstIndex(of: identifier) {
            HLLDefaults.calendar.enabledCalendars.remove(at: index)
        }
        
        if !HLLDefaults.calendar.disabledCalendars.contains(identifier) {
            HLLDefaults.calendar.disabledCalendars.append(identifier)
        }
        
    }
    
    func toggleWith(identifier: String) {
        
        if HLLDefaults.calendar.enabledCalendars.contains(identifier) {
            
            setDisabledWith(identifier: identifier)
            
        } else {
            
            setEnabledWith(identifier: identifier)
        }
        
    }
    
}
