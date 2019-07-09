//
//  MagdaleneSchoolHolidays.swift
//  How Long Left
//
//  Created by Ryan Kontos on 1/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class MagdaleneSchoolHolidays {
    
    // static var SHstartDate: Date?
    // static var SHendDate: Date?
    
    var holidayPeriods = [SchoolHolidaysPeriod]()
    
    var currentTerm: Int? {
    
        get {
        
       return MagdaleneSchoolHolidays().getNextHolidays()?.holidaysTerm
        
        
        }
    }
    
    init() {
        
        
        
        let start = NSDateComponents()
        let end = NSDateComponents()
        
        // Term 1 Holidays 2019
        
        start.year = 2019
        start.month = 4
        start.day = 12
        start.hour = 14
        start.minute = 35
        start.second = 00
       
        end.year = 2019
        end.month = 4
        end.day = 29
        end.hour = 8
        end.minute = 15
        end.second = 00
        holidayPeriods.append(SchoolHolidaysPeriod(startComp: start, endComp: end, term: 1))
        
        // Term 2 Holidays 2019
        
        start.year = 2019
        start.month = 7
        start.day = 4
        start.hour = 14
        start.minute = 35
        start.second = 00
        
        end.year = 2019
        end.month = 7
        end.day = 22
        end.hour = 8
        end.minute = 15
        end.second = 00
        holidayPeriods.append(SchoolHolidaysPeriod(startComp: start, endComp: end, term: 2))
        
        // Term 3 Holidays 2019
        
        start.year = 2019
        start.month = 9
        start.day = 27
        start.hour = 14
        start.minute = 35
        start.second = 00
        
        end.year = 2019
        end.month = 10
        end.day = 14
        end.hour = 8
        end.minute = 15
        end.second = 00
        holidayPeriods.append(SchoolHolidaysPeriod(startComp: start, endComp: end, term: 3))
        
        
    }
    
    func getNextHolidays() -> HLLEvent? {
        
        return getSchoolHolidaysFrom(start: Date(), end: Date.distantFuture)
        
    }
    
   func getPreviousHolidays() -> HLLEvent? {
    
    if HLLDefaults.magdalene.doHolidays == false || SchoolAnalyser.schoolMode != .Magdalene {
        return nil
    }
    
    var endedArray = [HLLEvent]()
    
    for holidayPeriod in holidayPeriods {
        
        if let unwrappedSHStart = holidayPeriod.start, let unwrappedSHEnd = holidayPeriod.end {
            
            if unwrappedSHStart.timeIntervalSinceNow < 0 {
                
                let holidaysEvent = HLLEvent(title: "Holidays", start: unwrappedSHStart, end: unwrappedSHEnd, location: nil)
                holidaysEvent.holidaysTerm = holidayPeriod.term
                holidaysEvent.calendar = SchoolAnalyser.schoolCalendar
                //holidaysEvent.shortTitle = "Holidays"
                
                endedArray.append(holidaysEvent)
                
            }
            
        }
        
    }
    
    return endedArray.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending }).last

        
    }
    
    func getSchoolHolidaysFrom(start: Date, end: Date) -> HLLEvent? {
        
        if HLLDefaults.magdalene.doHolidays == false || SchoolAnalyser.schoolMode != .Magdalene {
            return nil
        }
        
        var returnEvent: HLLEvent?
        
        for holidayPeriod in holidayPeriods {
        
        if let unwrappedSHStart = holidayPeriod.start, let unwrappedSHEnd = holidayPeriod.end {
          
            if unwrappedSHStart.timeIntervalSince(end) < 0, unwrappedSHEnd.timeIntervalSince(start) > 0 {
                
                let holidaysEvent = HLLEvent(title: "Holidays", start: unwrappedSHStart, end: unwrappedSHEnd, location: nil)
                holidaysEvent.holidaysTerm = holidayPeriod.term
                holidaysEvent.calendar = SchoolAnalyser.schoolCalendar
                //holidaysEvent.shortTitle = "Holidays"
                
                returnEvent = holidaysEvent
                break
                
            }
            
        }
        
    }
        
        return returnEvent
    
    }
    
}

struct SchoolHolidaysPeriod {
    
    init(startComp: NSDateComponents, endComp: NSDateComponents, term holidaysTerm: Int) {
        
        start = (NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: startComp as DateComponents))!
        end = (NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: endComp as DateComponents))!
        
        term = holidaysTerm
    }
    
    var start: Date?
    var end: Date?
    var term: Int
}
