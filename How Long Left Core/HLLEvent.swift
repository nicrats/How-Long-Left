//
//  HLLEvent.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

/**
 * Represents an event in How Long Left. A HLLEvent can be initalized from an EKEvent or with custom data.
 */

struct HLLEvent: Equatable, Hashable, Comparable {
    
    var title: String
    var shortTitle: String
    var originalTitle: String
    var startDate: Date
    var endDate: Date
    var duration: TimeInterval
    var location: String?
    var fullLocation: String?
    var isDouble = false
    var isHolidays = false
    var magdalenePeriod: String?
    var calendar: EKCalendar?
    var isMagdaleneBreak = false
    var sourceEKEvent: EKEvent?
    var creationTime = Date()
    var completionStatus: EventCompletionStatus {
        
        get {
            
            if self.startDate.timeIntervalSinceNow > 0 {
                return .NotStarted
            } else {
                if self.endDate.timeIntervalSinceNow < 1 {
                    return .Done
                } else {
                    return .InProgress
                    
    } } } }
    
    init(event: EKEvent) {
        
        // Init a HLLEvent from an EKEvent.
        
        title = event.title.truncated(limit: 15, position: .tail, leader: "...")
        originalTitle = event.title
        shortTitle = event.title.truncated(limit: 15, position: .tail, leader: "...")
        startDate = event.startDate
        endDate = event.endDate
        sourceEKEvent = event
        
        if let loc = event.location, loc != "" {
            let truncatedLocation = loc.truncated(limit: 15, position: .tail, leader: "...")
            if HLLDefaults.general.showLocation {
                location = truncatedLocation
            }
            fullLocation = loc
            
        }
        
        if let cal = event.calendar {
            
            calendar = cal
            
        }
        
        duration = endDate.timeIntervalSince(startDate)
        
        
    }
    
    init(title inputTitle: String, start inputStart: Date, end inputEnd: Date, location inputLocation: String?) {
        
        // Init a HLLEvent from custom data.
        
        title = inputTitle
        originalTitle = inputTitle
        shortTitle = inputTitle
        startDate = inputStart
        endDate = inputEnd
        
        if let loc = inputLocation, loc != "" {
            
            if HLLDefaults.general.showLocation {
                location = loc
            }
            fullLocation = loc
            
        }
        
        duration = endDate.timeIntervalSince(startDate)
        
    }
    
    
    static func == (lhs: HLLEvent, rhs: HLLEvent) -> Bool {
        
        return lhs.title == rhs.title && lhs.startDate == rhs.startDate && lhs.location == rhs.location && lhs.calendar == rhs.calendar
        
    }
    
    static func < (lhs: HLLEvent, rhs: HLLEvent) -> Bool {
        
        if lhs.startDate < rhs.startDate {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func convertToEKEvent() -> EKEvent {
        
        let event = EKEvent()
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = fullLocation
        event.calendar = calendar
        event.notes = sourceEKEvent?.notes
        return event
        
    }
    
}
