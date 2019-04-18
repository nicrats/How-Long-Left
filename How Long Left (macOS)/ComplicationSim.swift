//
//  ComplicationSim.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 19/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

class ComplicationSim {
    
    let cal = EventDataSource()
    
    init() {
        
        SchoolAnalyser.shared.analyseCalendar()
        
    }
    
    func generateComplicationItems() -> [HLLComplicationEntry] {
        
        
        cal.updateEventStore()
        var events = cal.fetchEventsFromPresetPeriod(period: .AllToday)
        
        events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        
        var startDatesArray = [Date]()
        var endDatesArray = [Date]()
        
        for event in events {
            
            startDatesArray.append(event.startDate)
            endDatesArray.append(event.endDate)
            
            if event.completionStatus == .Done {
                
                if let index = events.firstIndex(of: event) {
                    
                    events.remove(at: index)
                    
                }
                
            }
            
        }
        
        //    var processedEvents = [HLLEvent]()
        
        var dictOfAdded = [Date:HLLEvent]()
        
        var returnItems = [HLLComplicationEntry]()
        
        for item in events {
            
            if let start = getSoonestEndingEvent(at: item.startDate, from: events) {
                
                let next = getNextEvent(after: start, events: events)
                
                print("CompSim1: \(item.startDate.formattedTime()): \(start.title), Next: \(String(describing: next?.title))")
                returnItems.append(HLLComplicationEntry(date: item.startDate, event: start, next: next))
                dictOfAdded[item.startDate] = start
                
            } else {
                
                let nextEv = getNextEventToStart(after: item.startDate, from: events)
                print("CompSim2: \(item.startDate.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: nil, next: nextEv))
                
            }
            
            if let end = getSoonestEndingEvent(at: item.endDate, from: events) {
                
                
                let next = getNextEvent(after: end, events: events)
                
                print("CompSim3: \(item.endDate.formattedTime()): \(end.title), Next: \(String(describing: next?.title))")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: end, next: next))
                dictOfAdded[item.endDate] = end
                
            } else {
                
                let nextEv = getNextEventToStart(after: item.endDate, from: events)
                print("CompSim4: \(item.endDate.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: item.endDate, event: nil, next: nextEv))
                
                
            }
            
            if cal.getCurrentEvents().isEmpty == true {
                
                print("CompSim5: \(Date().formattedTime()): No event is on")
                returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: events.first))
                
            }
            
            
        }
        
        
        
        if returnItems.isEmpty == true {
            
            print("CompSim6: \(Date().formattedTime()): No event is on")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: events.first))
        }
        
        returnItems.sort(by: { $0.showAt.compare($1.showAt) == .orderedAscending })
        
        return returnItems
    }
    
    
    
    private func generateEventComlicationText(event: HLLEvent, next: HLLEvent?) -> String {

    
        
        
        return ""
        
    }
    
    func generateNoEventOnComlicationText(nextEvent: HLLEvent?) {
        
        
        
    }
    
    func getTimelineStartDate() -> Date? {
        
        let cal = EventDataSource()
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllToday).first?.startDate
        
    }
    
    func getTimelineEndDate() -> Date? {
        let cal = EventDataSource()
        cal.updateEventStore()
        return cal.fetchEventsFromPresetPeriod(period: .AllToday).last?.endDate
        
    }
    
    


func getSoonestEndingEvent(at date: Date, from events: [HLLEvent]) -> HLLEvent? {
    
    var currentEvents = [HLLEvent]()
    
    for event in events {
        
        if event.startDate.timeIntervalSince(date) < 1, event.endDate.timeIntervalSince(date) > 0 {
            
            currentEvents.append(event)
            
        }
    }
    
    currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
    
    return currentEvents.first
    
}


func getNextEvent(after event: HLLEvent, events: [HLLEvent]) -> HLLEvent? {
    
    if let index = events.firstIndex(of: event) {
        
        if events.indices.contains(index+1) {
            
            return events[index+1]
            
        } else {
            
            return nil
            
        }
        
    } else {
        
        return nil
        
    }
    
    
}

}

func getNextEventToStart(after date: Date, from events: [HLLEvent]) -> HLLEvent? {
    
    var upcomingEvents = [HLLEvent]()
    
    for event in events {
        
        if event.startDate.timeIntervalSinceNow > 0 {
            
            upcomingEvents.append(event)
            
        }
    }
    
    return upcomingEvents.first
    
    
}

class HLLComplicationEntry {
    
    var showAt: Date
    var event: HLLEvent?
    var nextEvent: HLLEvent?
    
    init(date: Date, event currentEvent: HLLEvent?, next: HLLEvent?) {
        showAt = date
        event = currentEvent
        nextEvent = next
    }
    
}

