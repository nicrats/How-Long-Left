//
//  SchoolHolidayEventFetcher.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 19/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolHolidayEventFetcher {
    
    let holidaysStore = SchoolHolidayPeriodsStore()
    
    var currentTerm: Int? {
        
        get {
            
            return self.getNextHolidays()?.holidaysTerm
            
            
        }
    }
    
    func getNextHolidays() -> HLLEvent? {
        
        return getSchoolHolidaysFrom(start: Date(), end: Date.distantFuture)
        
    }
    
    func getCurrentHolidays() -> HLLEvent? {
        
        var returnEvent: HLLEvent?
        
        if let next = getNextHolidays() {
            
            if next.completionStatus == .Current {
                
                returnEvent = next
                
            }
            
        }
        
        return returnEvent
    }
    
    func getUpcomingHolidays() -> HLLEvent? {
        
        return getSchoolHolidaysFrom(start: Date(), end: Date.distantFuture, excludeOnNow: true)
        
    }
    
    func getPreviousHolidays() -> HLLEvent? {
        
        if SchoolAnalyser.schoolMode != .Magdalene {
            return nil
        }
        
        var endedArray = [HLLEvent]()
        
        for holidayPeriod in holidaysStore.holidayPeriods {
            
            if holidayPeriod.start.timeIntervalSinceNow < 0 {
                
                endedArray.append(createHolidaysHLLEvent(from: holidayPeriod))
                
            }
            
            
            
        }
        
        return endedArray.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending }).last
        
        
    }
    
    func getSchoolHolidaysFrom(start: Date, end: Date, excludeOnNow: Bool = false) -> HLLEvent? {
        
        if SchoolAnalyser.schoolMode != .Magdalene {
            return nil
        }
        
        var returnEvent: HLLEvent?
        
        for holidayPeriod in holidaysStore.holidayPeriods {
            
            if holidayPeriod.start.timeIntervalSince(end) < 0, holidayPeriod.end.timeIntervalSince(start) > 0 {
                
                returnEvent = createHolidaysHLLEvent(from: holidayPeriod)
                
                if returnEvent!.completionStatus == .Current {
                    
                    if excludeOnNow == false {
                        
                        break
                        
                    }
                    
                } else {
                    
                    break
                    
                }
                
            }
            
            
            
        }
        
        return returnEvent
        
    }
    
    func createHolidaysHLLEvent(from period: SchoolHolidaysPeriod) -> HLLEvent {
        
        var holidaysEvent = HLLEvent(title: "Holidays", start: period.start, end: period.end, location: nil)
        holidaysEvent.titleReferencesMultipleEvents = true
        holidaysEvent.holidaysTerm = period.term
        holidaysEvent.useSchoolCslendarColour = true
        holidaysEvent.visibilityString = .holidays
        return holidaysEvent
    }
    
    
}
