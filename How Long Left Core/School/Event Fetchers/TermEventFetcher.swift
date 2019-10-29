//
//  TermEventFetcher.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 19/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class TermEventFetcher {
    
    let holidaysFetcher = SchoolHolidayEventFetcher()
    
    func getCurrentTermEvent() -> HLLEvent? {
    
        var returnEvent: HLLEvent?
        
        if let previous = holidaysFetcher.getPreviousHolidays(), let next = holidaysFetcher.getUpcomingHolidays(), let termNumber = next.holidaysTerm {
            
            var termEvent = HLLEvent(title: "Term \(termNumber)", start: previous.endDate, end: next.startDate, location: nil)
            termEvent.isHidden = true
            termEvent.isTerm = true
            termEvent.visibilityString = VisibilityString.term
            
            print("Creating term event with cal \(String(describing: SchoolAnalyser.schoolCalendar?.title))")
            
            termEvent.associatedCalendar = SchoolAnalyser.schoolCalendar
            returnEvent = termEvent
            
           /* DispatchQueue.global(qos: .background).async {
                
                var amount = 0
                
                var time = Date()
                var loops = 0
                
                while amount != 69 {
                 
                    loops += 1
                    
                time = time.addingTimeInterval(1)
                    
                let secondsElapsed = time.timeIntervalSince(termEvent.startDate)
                let totalSeconds = termEvent.endDate.timeIntervalSince(termEvent.startDate)
                amount = Int(100*secondsElapsed/totalSeconds)
                    
                }
                
                print("Found match: \(time.formattedDate()) \(time.formattedTime())")
                print ("With loops: \(loops)")
                
                
                
            } */
            
            
        }
    
        return returnEvent
        
    }
    
    
}
