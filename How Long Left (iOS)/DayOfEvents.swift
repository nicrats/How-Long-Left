//
//  DayOfEvents.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 22/4/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class DayOfEventsGenerator {
    
    let dataSource = EventDataSource()
    
    func generateDaysOfEventsFromUpcomingEvents() -> [DayOfEvents] {
        
        var returnArray = [DayOfEvents]()
        
        let dict = dataSource.getArraysOfUpcomingEventsForNextSevenDays()
        
        for dictItem in dict {
            
            if dictItem.value.isEmpty == false {
            let dOE = DayOfEvents(inputDate: dictItem.key, inputEvents: dictItem.value)
            returnArray.append(dOE)
            }
            
            
        }
        
        returnArray.sort(by: {
            
            $0.date.compare($1.date) == .orderedAscending
            
        })
        
        return returnArray
        
    }
    
    
}

struct DayOfEvents: Equatable {

    let events: [HLLEvent]

    let date: Date
    let headerString: String
    
    
    init(inputDate: Date, inputEvents: [HLLEvent]) {
        
        date = inputDate
        events = inputEvents
        
        
        
         let firstUpcoming = self.events.first!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let formattedEnd = dateFormatter.string(from: firstUpcoming.startDate)
            
            let days = firstUpcoming.startDate.midnight().timeIntervalSince(Date().midnight())/60/60/24
            
            
            
            switch days {
            case 0:
                headerString = "Upcoming Today"
            case 1:
                headerString = "Tomorrow"
            default:
                headerString = "\(formattedEnd)"
            }
    }
    
    
}

class DummyEvent: Equatable {
    static func == (lhs: DummyEvent, rhs: DummyEvent) -> Bool {
        
        if lhs.startDateString == rhs.startDateString, lhs.endDateString == rhs.endDateString, lhs.titleString == rhs.titleString, lhs.progress == rhs.progress, lhs.location == rhs.location, lhs.timeRemainingString == rhs.timeRemainingString {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    
    var startDateString = ""
    var endDateString = ""
    var titleString = ""
    var progress = 0.0
    var location: String?
    var timeRemainingString = "0:00"
    
    
    
}

class DayOfDummyEvents {
    
    var events = [DummyEvent]()
    var headerString = ""
    
    init(dummyEvents inputEvents: [DummyEvent], header: String) {
        
        events = inputEvents
        headerString = header
        
    }
    
    
}
