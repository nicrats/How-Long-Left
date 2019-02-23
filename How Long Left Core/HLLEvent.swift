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

struct HLLEvent: Equatable, Hashable, Codable {
    
    var title: String
    var shortTitle: String
    var originalTitle: String
    var startDate: Date
    var endDate: Date
    var duration: TimeInterval {
        
        get {
            
            return self.endDate.timeIntervalSince(self.startDate)
            
        }
        
    }
    var location: String?
    var fullLocation: String?
    var isDouble = false
    var isHolidays = false
    var magdalenePeriod: String?
  //  var calendar: EKCalendar?
    var calendarID: String?
    var isMagdaleneBreak = false
   // var color: CGColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    //var sourceEKEvent: EKEvent?
    
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
        
        if let loc = event.location, loc != "" {
            let truncatedLocation = loc.truncated(limit: 15, position: .tail, leader: "...")
            if HLLDefaults.general.showLocation {
                location = truncatedLocation
            }
            fullLocation = loc
            
        }
        
        
        calendarID = event.calendar.calendarIdentifier
        
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
        
    }
    
    
    static func == (lhs: HLLEvent, rhs: HLLEvent) -> Bool {
        
        return lhs.title == rhs.title && lhs.startDate == rhs.startDate && lhs.location == rhs.location && lhs.calendarID == rhs.calendarID
        
    }
    
    
}
