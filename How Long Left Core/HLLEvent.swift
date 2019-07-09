//
//  HLLEvent.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit
import CoreLocation

/**
 * Represents an event in How Long Left. A HLLEvent can be initalized from an EKEvent or with custom data.
 */

class HLLEvent: Equatable {
    
    var title: String
    var shortTitle: String
    var originalTitle: String
    var ultraCompactTitle: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var fullLocation: String?
    var shortLocation: String?
    var CLLocation: CLLocation?
    var holidaysTerm: Int?
    var magdalenePeriod: String?
    var calendarID: String?
    var calendar: EKCalendar?
    var isMagdaleneBreak = false
    var EKEvent: EKEvent?
    var isSchoolEvent = false
    var source: EventDataSource!
    var endsInString: String {
        
        get {
        
        if self.holidaysTerm != nil {
            
            return "end"
            
        } else {
            
            return "ends"
            
        }
            
            
        }
        
    }
    
    var duration: TimeInterval {
        
        get {
            
            return self.endDate.timeIntervalSince(self.startDate)
            
        }
        
    }
    
    var complationPercentage: String? {
        
        get {
        
        let calc = PercentageCalculator()
        return calc.calculatePercentageDone(event: self, ignoreDefaults: true)
        
        
        }
    }
    
    var completionFraction: Double {
        
        get {
            
            let secondsElapsed = Date().timeIntervalSince(self.startDate)
            let totalSeconds = self.endDate.timeIntervalSince(self.startDate)
            return 100*secondsElapsed/totalSeconds
            
        }
    }
    
    var completionStatus: EventCompletionStatus {
        
        get {
            
            if self.startDate.timeIntervalSinceNow > 0 {
                return .NotStarted
            } else if self.endDate.timeIntervalSinceNow < 1 {
                return .Done
            } else {
                return .InProgress
            }
                
                
            }
            
        }
    
    var identifier: String {
        
        get {
            
            return "\(title) \(startDate) \(endDate) \(calendarID ?? "nil") \(location ?? "nil")"
            
            
        }
        
        
    }
    
    
    init(event: EKEvent) {
        
        // Init a HLLEvent from an EKEvent.
        
        
        title = event.title
        ultraCompactTitle = event.title
        originalTitle = event.title
        shortTitle = event.title.truncated(limit: 25, position: .tail, leader: "...")
        startDate = event.startDate
        endDate = event.endDate
        EKEvent = event
        
        if let loc = event.location, loc != "" {
            
            if HLLDefaults.general.showLocation {
                location = loc
                
                let truncatedLocation = loc.truncated(limit: 15, position: .tail, leader: "...")
                
                shortLocation = truncatedLocation
                
            }
            fullLocation = loc
            
        }
        
        
        calendarID = event.calendar.calendarIdentifier
        calendar = event.calendar
        
    }
    
    
    init(title inputTitle: String, start inputStart: Date, end inputEnd: Date, location inputLocation: String?) {
        
        // Init a HLLEvent from custom data.
        
        title = inputTitle
        originalTitle = inputTitle
        ultraCompactTitle = inputTitle
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
    
    func truncateTitle(limit: Int, postion: String.TruncationPosition) -> String {
        
        return title.truncated(limit: limit, position: postion, leader: "...")
        
        
    }
    
    func refresh() -> Bool {
        
        var returnValue = false
        
        if source == nil {
            
            source = EventDataSource()
            
        }
        
        if let ek = self.EKEvent {
        
            if let event = source.findEventWithIdentifier(id: ek.eventIdentifier) {
                
                title = event.title
                ultraCompactTitle = event.title
                originalTitle = event.title
                shortTitle = event.title.truncated(limit: 25, position: .tail, leader: "...")
                startDate = event.startDate
                endDate = event.endDate
                if let loc = event.location, loc != "" {
                    
                    if HLLDefaults.general.showLocation {
                        location = loc
                        
                        let truncatedLocation = loc.truncated(limit: 15, position: .tail, leader: "...")
                        
                        shortLocation = truncatedLocation
                        
                    }
                    fullLocation = loc
                    
                }
                
                
                
                calendar = event.calendar
                
                
                returnValue = true
                
            }
            
        }
        
        return returnValue
        
    }
    
    static func == (lhs: HLLEvent, rhs: HLLEvent) -> Bool {
        
        return lhs.title == rhs.title && lhs.startDate == rhs.startDate && lhs.location == rhs.location && lhs.calendarID == rhs.calendarID
        
    }
    
    
    
    
}
