//
//  ComplicationGenTest.swift
//  How Long Left (watchOS) Extension
//
//  Created by Ryan Kontos on 20/10/18.
//  Copyright © 2018 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

class ComplicationGenTest {
    
    
    let cal = CalendarData()
    
    func generateComplicationTextTest() -> [String] {
        
        var r = [String]()
        cal.updateEventStore()
        let events = cal.fetchEventsFromPresetPeriod(period: .Next24Hours)
        for (index, item) in events.enumerated() {
            
            var next: HLLEvent?
            
            if events.indices.contains(index+1) {
                next = events[index+1]
            }
            
            let gen = generateEventComlicationText(event: item, next: next)
            
            r.append(contentsOf: gen)
            
            var addNoEventsAfterThisEvent = false
            
            if let uNext = next {
                
                if item.endDate != uNext.startDate {
                    
                    addNoEventsAfterThisEvent = true
                    
                }
                
            } else {
                
                addNoEventsAfterThisEvent = true
                
            }
            
            if addNoEventsAfterThisEvent == true {
                
                let entry = generateNoEventOnComlicationText()
                
                let e = "\(item.endDate): \(entry)"
                r.append(e)
                
            }
            
            
        }
        
        
        if cal.getCurrentEvent() == nil {
            
            let entry = generateNoEventOnComlicationText()
            
            let e = "\(Date()): \(entry)"
            r.insert(e, at: 0)
            
        }
        
        
        if r.isEmpty == true {
            
            let entry = generateNoEventOnComlicationText()
            
            r.append("\(Date()): \(entry)")
            
        }
        
        return r
    }
    
    
    
    func generateNoEventOnComlicationText() -> String {
        

        return "No event is on"
        
    }
    
    
    private func generateEventComlicationText(event: EKEvent, next: EKEvent?) -> [String] {
        
        var rArray = [String]()
        
        let current = event

        var text = ""
        
        text = "\(current.startDate!): \(current.title!) ends at \(current.endDate!)"
        
        if let loc = current.location, loc != "" {
            
            text = "\(text), \(loc)"
            
        } else {
            
            text = "\(text), No location"
            
        }
        
        rArray.append(text)
        
        
        if let uNext = next {
            
            let nextName = uNext.title!
            
            if let loc = uNext.location, loc != "" {
                
                text = "\(current.startDate!): \(current.title!) ends at \(current.endDate!), \(nextName), \(loc)"
                
                
                
            } else {
                
                text = "\(current.startDate!): \(current.title!) ends at \(current.endDate!), Next: \(nextName)"
                
            }
            
        } else {
            
           text = "\(current.startDate!): \(current.title!) ends at \(current.endDate!), Nothing Next"
            
        }
        
        rArray.append(text)
        
        return rArray
        
    }
    
    func getTimelineStartDate() -> Date? {
        
        cal.updateEventStore()
        return cal.fetchEvents(period: EventFetchPeriod.Next24Hours).first?.startDate
        
    }
    
    func getTimelineEndDate() -> Date? {
        
        cal.updateEventStore()
        return cal.fetchEvents(period: EventFetchPeriod.Next24Hours).last?.endDate
        
    }
    
    
}
