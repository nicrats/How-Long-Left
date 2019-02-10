//
//  UpcomingEventStringGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 1/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class UpcomingEventStringGenerator {
    
    var schoolAnalyser = SchoolAnalyser()
    
    func generateNextEventString(upcomingEvents: [HLLEvent], currentEvents: [HLLEvent], isForDoneNotification: Bool) -> String? {
        
        var returnString: String?
    
        if HLLDefaults.general.showNextEvent == true {
        
        if upcomingEvents.isEmpty == false {
            
            let nextEvent = upcomingEvents[0]
            
            var nextNonBreakEvent = nextEvent
            
            if currentEvents.isEmpty == false {
            
                if nextEvent.startDate.timeIntervalSinceNow > 1 {
                    
                    returnString = "\(nextEvent.title) starts next"
                    
                } else {
                    
                    returnString = "\(nextEvent.title) is starting now"
                    
                }
            
            if nextEvent.title.containsAnyOfThese(Strings: ["Recess","Lunch"]), SchoolAnalyser.schoolMode == .Magdalene {
                
                if let afterNextEvent = upcomingEvents[safe: 1] {
                    
                    nextNonBreakEvent = afterNextEvent
                    
                    returnString = "\(returnString!), then \(afterNextEvent.title)"
                
                }
                
            } else {
            
                if currentEvents.isEmpty == false {
                
                let currentEvent = currentEvents[0]
                
                    if currentEvent.endDate != nextEvent.startDate {
                        returnString = "\(returnString!), at \(nextEvent.startDate.formattedTime())"
                    }
               
                }
                
            }
                
            returnString = "\(returnString!)."
            
            if let nextEventLocation = nextNonBreakEvent.location, HLLDefaults.general.showLocation == true {
                
                returnString = "\(returnString!) (\(nextEventLocation))"
                
            }
            
            } else {
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .full
                let timeUntilStartFormatted = formatter.string(from: nextEvent.startDate.timeIntervalSinceNow+60)!
                
                returnString = "\(nextEvent.title) starts in \(timeUntilStartFormatted)."
                
            }
            
        } else {
            
            returnString = "No upcoming events today."
            
        }
            
        }
        
        return returnString
    }
    
    func generateUpcomingEventsMenuStrings(upcoming events: [HLLEvent]) -> (String, [String], [String]) {
        
        var menuTitle = "No events found within the next 7 days."
        var infoItems = [String]()
        var eventItems = [String]()
        
        if events.isEmpty == false {
        
            
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        let midnightToday = NSCalendar.current.date(from: comp)!
        
        let daysUntilUpcomingStart = Int(events[0].startDate.timeIntervalSince(midnightToday))/60/60/24
            
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let formattedEnd = dateFormatter.string(from: events[0].startDate)
            
            var dayText = formattedEnd
            
            var eventsPluralised = "event"
            if events.count != 1 {
                eventsPluralised += "s"
            }
            
            switch daysUntilUpcomingStart {
            case 0:
                dayText = "Today"
                menuTitle = "All Upcoming Today"
                infoItems.append("\(events.count) upcoming \(eventsPluralised) today.")
                
                let interval = Int(events.last!.endDate.timeIntervalSinceNow)+60
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .full
                
                let formattedString = formatter.string(from: TimeInterval(interval))!
                
                infoItems.append("All done in \(formattedString).")
                
            case 1:
                dayText = "Tomorrow"
                menuTitle = "Events on Tomorrow (\(events.count))"
              //  infoItems.append("\(events.count) \(eventsPluralised) on tomorrow...")
            default:
                dayText = formattedEnd
                menuTitle = "Events on \(dayText) (\(events.count))"
              //  infoItems.append("\(events.count) \(eventsPluralised) on \(dayText)...")
            }
            

        for event in events {
            
            var titleAndMaybeLocation = event.title
            
            if let location = event.location, HLLDefaults.general.showLocation == true {
                titleAndMaybeLocation += " (\(location))"
            }
            
            var eventTimeInfo = event.startDate.formattedTime()
            
            if let period = event.magdalenePeriod {
                
                eventTimeInfo = "Period \(period)"
                
            }
                
            
            
            eventItems.append("\(eventTimeInfo): \(titleAndMaybeLocation)")
            
        }
         
        }
        
        return (menuTitle, infoItems, eventItems)
        
        
    }
    
    func generateUpcomingDayItems(days: [Date:[HLLEvent]]) -> [upcomingDayOfEvents] {
        
        var returnArray = [upcomingDayOfEvents]()
        
        for dayObject in days {
            
            
            var menuTitle = ""
            //var infoItems = [String]()
            var eventItems = [String]()
            var eventsArray = [HLLEvent]()
            
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
            comp.timeZone = TimeZone.current
            let midnightToday = NSCalendar.current.date(from: comp)!
            
            let daysUntilUpcomingStart = Int(dayObject.key.timeIntervalSince(midnightToday))/60/60/24
            
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let formattedEnd = dateFormatter.string(from: dayObject.key)
            
            var dayText = formattedEnd
            
            var eventsPluralised = "event"
            if dayObject.value.count != 1 {
                eventsPluralised += "s"
            }
            
            switch daysUntilUpcomingStart {
            case 0:
                dayText = "Today"
                menuTitle = "Today (\(dayObject.value.count) \(eventsPluralised))"
                
                
            default:
                dayText = formattedEnd
                menuTitle = "\(dayText) (\(dayObject.value.count) \(eventsPluralised))"
            }
            
            if dayObject.value.isEmpty == false {
                
                
                for event in dayObject.value {
                    
                    var titleAndMaybeLocation = event.title
                    
                    if let location = event.location, HLLDefaults.general.showLocation == true {
                        titleAndMaybeLocation += " (\(location))"
                    }
                    
                    var eventTimeInfo = event.startDate.formattedTime()
                    
                    if let period = event.magdalenePeriod {
                        
                        eventTimeInfo = "Period \(period)"
                        
                    }
                    
                    eventItems.append("\(eventTimeInfo): \(titleAndMaybeLocation)")
                    eventsArray.append(event)
                    
                }
                
            }
            
            returnArray.append(upcomingDayOfEvents(rowTitle: menuTitle, eventStringItems: eventItems, eventsDate: dayObject.key, events: eventsArray))
            
            
        }

        returnArray.sort(by: {
            
            $0.date.compare($1.date) == .orderedAscending
            
        })
        
       return returnArray
    }
    
    
}

struct upcomingDayOfEvents {
    
    var menuTitle: String
    var eventStrings: [String]
    var HLLEvents: [HLLEvent]
    var date: Date

    
    init(rowTitle: String, eventStringItems: [String], eventsDate: Date, events: [HLLEvent]) {
        
        menuTitle = rowTitle
        eventStrings = eventStringItems
        HLLEvents = events
        date = eventsDate
        
    }
    
}

