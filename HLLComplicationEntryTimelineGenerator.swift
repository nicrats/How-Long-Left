//
//  HLLComplicationEntryTimelineGenerator.swift
//  How Long Left
//
//  Created by Ryan Kontos on 29/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

/*
import Foundation

class HLLComplicationEntryTimelineGenerator {
    
    static var shared = HLLComplicationEntryTimelineGenerator()
    
    
    func generateComplicationItems() -> [HLLComplicationEntry] {
        
        HLLDefaults.defaults.set("Update started", forKey: "ComplicationDebug")
        HLLDefaults.defaults.set(Date().formattedTime(), forKey: "ComplicationDebugTime")
        
        var events = HLLEventSource.shared.eventPool
        events.sort(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        var entryDates = [Date]()
        
        for event in events {
            
            entryDates.append(event.startDate)
            entryDates.append(event.endDate)
            
            if event.completionStatus == .Done {
                
                if let index = events.firstIndex(of: event) {
                    
                    events.remove(at: index)
                    
                }
                
            }
            
        }

        
        if events.isEmpty {
            
            HLLDefaults.defaults.set("No events", forKey: "ComplicationDebug")
            
        } else {
            
            HLLDefaults.defaults.set("\(events.count) Events found", forKey: "ComplicationDebug")
            
        }
        
        
        var dictOfAdded = [Date:HLLEvent]()
        
        var returnItems = [HLLComplicationEntry]()
        
        for date in entryDates {
            
            if let current = getSoonestEndingEvent(at: date, from: events) {
                
                let next = getNextEventToStart(after: current.startDate, from: events)
                
                print("CompSim1: \(date.formattedDate()) \(date.formattedTime()): \(current.title), Next: \(String(describing: next?.title))")
                
                let entry = HLLComplicationEntry(date: date, event: current, next: next)
                
                if getSoonestEndingEvent(at: current.startDate.addingTimeInterval(600), from: events) != current {
                    
                    entry.switchToNext = false
                    
                }
                
                returnItems.append(entry)
                dictOfAdded[date] = current
                
                
                
                
            } else {
                
                let nextEv = getNextEventToStart(after: date, from: events)
                print("CompSim2: \(date.formattedDate()) \(date.formattedTime()): No events are on")
                returnItems.append(HLLComplicationEntry(date: date, event: nil, next: nextEv))
                
            }
            
        }
        
        if HLLEventSource.shared.getCurrentEvents().isEmpty == true {
            
            let nextEv = getNextEventToStart(after: Date(), from: events)
            
            print("CompSim5: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: nextEv))
            
        }
        
        if returnItems.isEmpty == true {
            
            let nextEv = getNextEventToStart(after: Date(), from: events)
            
            print("CompSim6: \(Date().formattedDate()) \(Date().formattedTime()): No event is on, Next: \(nextEv?.title ?? "None")")
            returnItems.append(HLLComplicationEntry(date: Date(), event: nil, next: nextEv))
            HLLDefaults.defaults.set("returnItems empty", forKey: "ComplicationDebug")
        }
        
        
        returnItems.sort(by: { $0.showAt.compare($1.showAt) == .orderedAscending })
        
        ComplicationUpdateHandler.shared.didComplicationUpdate()
        
        return returnItems
    }
    
    
    
}
*/
