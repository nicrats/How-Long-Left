//
//  HLLEvent.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

/**
 *  Represents an event in How Long Left.
 */

struct HLLEvent: Equatable, Hashable {
    
    var title: String
    var shortTitle: String
    var originalTitle: String
    var ultraCompactTitle: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var fullLocation: String?
    var shortLocation: String?
    var holidaysTerm: Int?
    var period: String?
    var calendarID: String?
    var calendar: EKCalendar?
    var associatedCalendar: EKCalendar?
    var useSchoolCslendarColour = false
    var isMagdaleneBreak = false
    var isTerm = false
    var isPrelims = false
    var isHidden = false
    var isFeatured = false
    var EKEvent: EKEvent?
    var notes: String?
    var isAllDay = false
    var isSchoolEvent = false
    var isBirthday = false
    var source: HLLEventSource!
    var titleReferencesMultipleEvents = false
    var visibilityString: VisibilityString?
    
    
    #if os(macOS)
    
    var nsColor: NSColor {
        
        get {
            
            var returnColour = NSColor.textColor
            
            if let cal = self.associatedCalendar {
                
                returnColour = cal.color
                
            }
            
            if useSchoolCslendarColour, let schoolCalendar = SchoolAnalyser.schoolCalendar {
                returnColour = schoolCalendar.color
            }
            
            return returnColour
            
        }
        
        
    }
    
    #else
    
    var uiColor: UIColor {
        
        get {
            
            var returnColour = UIColor.black
            
            #if os(iOS)
            
            if #available(iOS 13.0, *) {
                returnColour = UIColor.label
            }
            
            #endif
            
            #if os(watchOS)
                returnColour = UIColor.HLLOrange
            #endif

            if let cal = self.associatedCalendar {
                returnColour = UIColor(cgColor: cal.cgColor)
            }
            
            return returnColour.catalystAdjusted()
            
            
        }
        
        
        
    }
    
    
    #endif
    
    
    var calendarForColour: EKCalendar? {
        
        get {
            
            if let cal = calendar {
                
                    return cal
            
            }
            
            if let cal = associatedCalendar {
                
                return cal
                
            }
            
            return nil
        }
        
    }
    
    var countdownTypeString: String {
        
        get {
        
            var returnText = "end"
            
            if self.completionStatus == .Upcoming {
                
                returnText = "start"
            }
            
            
            if !titleReferencesMultipleEvents {
                
                returnText += "s"
                
                
            }
            
            return returnText
            
        }
        
        
    }
    
    
    
    var countdownStringEnd: String {
        
        get {
        
            var returnText = "end"
            
            if !titleReferencesMultipleEvents {
                
                returnText += "s"
                
                
            }
            
            return returnText
            
        }
        
        
    }
    
    var countdownStringStart: String {
        
        get {
        
            var returnText = "start"
            
            if !titleReferencesMultipleEvents {
                
                returnText += "s"
                
                
            }
            
            return returnText
            
        }
        
        
    }
    
    var countdownDate: Date {
        
        get {
            
            if self.completionStatus == .Upcoming {
                
                return startDate
                
            } else {
                
                return endDate
                
            }
            
            
        }
        
        
    }
    
    var duration: TimeInterval {
        
        get {
            
            return self.endDate.timeIntervalSince(self.startDate)
            
        }
        
    }
    
    var completionPercentage: String? {
        
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
                return .Upcoming
            } else if self.endDate.timeIntervalSinceNow < 0 {
                return .Done
            } else {
                return .Current
            }
                
        }
            
    }
    
    var compactInfoText: String {
        
        get {
            
            var infoText = startDate.formattedTime()
                   
                   if let location = location {
                       
                       infoText = "\(location) | \(infoText)"
                       
                   }
                   
                   if startDate.daysUntil() != 0 {
                       
                       infoText = "\(startDate.getDayOfWeekName(returnTodayIfToday: true)) | \(startDate.formattedTime())"
                       
                   }
            
            return infoText
            
        }
        
    }
    
    var identifier: String {
        
        get {
            
           
            let id =  "\(title) \(startDate) \(endDate) \(calendarID ?? "nil") \(location ?? "nil")"
            return id.replacingOccurrences(of: " ", with: "")
            
            
        }
        
    }
    
    var followingOccurence: HLLEvent? {
        
        get {
            
          return FollowingOccurenceStore.shared.nextOccurDictionary[identifier]
            
            
        }
        
        
    }
    
    var hasMagdalenePeriod: Bool {
        
        get {
            
            return self.period != nil
            
        }
        
        
    }
    
    init(event: EKEvent) {
        
        // Init a HLLEvent from an EKEvent.
       // print("Creating event \(event.title)")
        
        if let safeTitle = event.title {
        
            title = safeTitle
            
            
        } else {
            
            title = "Nil"
            
        }
        
        ultraCompactTitle = title
        originalTitle = title
        shortTitle = title.truncated(limit: 25, position: .tail, leader: "...")
        
        
        startDate = event.startDate
        endDate = event.endDate
        notes = event.notes
        isAllDay = event.isAllDay
        EKEvent = event
        
        if let loc = event.location, loc != "" {
            
            if HLLDefaults.general.showLocation {
                location = loc
                
                let truncatedLocation = loc.truncated(limit: 15, position: .tail, leader: "...")
                
                shortLocation = truncatedLocation
                
            }
            fullLocation = loc
            
        }
        
        if let cal = event.calendar {
            
            calendarID = cal.calendarIdentifier
            calendar = cal
            associatedCalendar = cal
            
        }
        
        
        
        isBirthday = event.birthdayContactIdentifier != nil
        
        
        
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
    
    mutating func refresh() -> HLLEvent? {
        
        var returnValue: HLLEvent?
        
        var id = self.identifier
        
        if let eventID = self.EKEvent?.eventIdentifier {
            id = eventID
        }
        
        if let event = HLLEventSource.shared.findEventWithIdentifier(id: id) {
                
            self = event
            returnValue = event 
                
        }
            
        
        return returnValue
        
    }
    
    static func == (lhs: HLLEvent, rhs: HLLEvent) -> Bool {
        
        return lhs.identifier == rhs.identifier
        
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
   
  /*  func relationTo(_ event: HLLEvent) -> HLLEventTimeRelation {
        
        if event.startDate == startDate, event.endDate == endDate {
            
            return .StartsWithEndsWith
            
        }
        
        if event.startDate.timeIntervalSince(startDate) > 0 {
            
            // Event starts before
            
            if event.endDate.timeIntervalSince(endDate) > 0 {
                
                // Event ends before
                
                return .StartsBeforeEndsBefore
                
                
            } else {
                
                return .StartsBeforeEndsBefore
                
            }
            
            
        }
        
    } */
    
}

enum HLLEventTimeRelation {
    
    case StartsBeforeEndsBefore
    case StartsBeforeEndsDuring
    case StartsBeforeEndsAfter
    case StartsWithEndsDuring
    case StartsWithEndsWith
    case StartsWithEndsAfter
    case StartsAfterEndsAfter
    case StartsImmediatelyAfter
    case EndsImmediatelyBefore
    
}
