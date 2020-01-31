//
//  EventNotificationContentGenerator.swift
//  How Long Left
//
//  Created by Ryan Kontos on 25/11/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

class EventNotificationContentGenerator {
    
    let countdownStringGenerator = CountdownStringGenerator()
    let percentageCalculator = PercentageCalculator()
    
    let minutePluraliser = Pluraliser(singular: "minute", plural: "minutes")
    
    func generateNotificationContentItems(for events: [HLLEvent]) -> [HLLNotificationContent] {
        
        var contentItems = [HLLNotificationContent]()
        var startingEventsIncludedInEndNotifications = [HLLEvent]()
        
      /*  var startGroups = [HLLEventGroup]()
        var startDict = [Date:[HLLEvent]]()
        
        for event in events {
            
            if var array = startDict[event.startDate] {
                array.append(event)
                startDict[event.startDate] = array
            } else {
                startDict[event.startDate] = [event]
            }
        
        }
        
        for item in startDict.values {
            
            startGroups.append(HLLEventGroup(item))
            
        }
        
        var endGroups = [HLLEventGroup]()
        var endDict = [Date:[HLLEvent]]()
        
        for event in events {
            
            if var array = endDict[event.endDate] {
                array.append(event)
                endDict[event.endDate] = array
            } else {
                endDict[event.endDate] = [event]
            }
        
        }
        
        for item in endDict.values {
            
            endGroups.append(HLLEventGroup(item))
            
        }
        
        
        */
        
        for event in events {
            
            // Generate end notification for event.
            
            if HLLDefaults.notifications.endNotifications {
                
                let title = "\(event.truncatedTitle()) is done"
                
                let content = HLLNotificationContent(date: event.endDate)
                content.title = title
                
                let upcomingData = getUpcomingEventData(at: event.endDate, from: events, exclude: event)
                
                if let event = upcomingData.event, upcomingData.startingNow {
                    startingEventsIncludedInEndNotifications.append(event)
                }
                
                content.body = upcomingData.string
                
                content.event = event
                
                contentItems.append(content)
                
            }
            
            // Generate start notification for event.
            
            if HLLDefaults.notifications.startNotifications, !startingEventsIncludedInEndNotifications.contains(event) {
                
                let title = "\(event.truncatedTitle()) is starting now"
                
                let content = HLLNotificationContent(date: event.startDate)
                content.title = title
                if let location = event.location?.truncated(limit: 15) {
                  content.subtitle = "(\(location))"
                }
                
                let upcomingData = getUpcomingEventData(at: event.startDate, from: events, exclude: event)
                content.body = upcomingData.string
                
                content.event = event
                
                contentItems.append(content)
                
            }
            
            // Generate time remaining notifications for event.
            
            for secondsRemaining in HLLDefaults.notifications.milestones {
                
                let date = event.endDate.addingTimeInterval(TimeInterval(0 - secondsRemaining))

                if event.completionStatus(at: date) == .Current {
                
                let content = HLLNotificationContent(date: date)
                
                let minutesRemaining = secondsRemaining/60
                    
                let title = "\(event.truncatedTitle()) \(event.countdownStringEnd) in \(minutesRemaining) \(minutePluraliser.pluralise(from: minutesRemaining))"
                    
                if secondsRemaining == 60, SchoolAnalyser.schoolMode == .Magdalene {
                    
                    content.title = "We're in the endgame now..."
                    content.subtitle = title
                        
                } else {
                    
                    content.title = title
                    content.subtitle = "(\(percentageCalculator.calculatePercentageDone(for: event, at: date)) done)"
                    
                }
                    
                let upcomingData = getUpcomingEventData(at: date, from: events, exclude: event)
                content.body = upcomingData.string
                content.event = event
                
                contentItems.append(content)
                    
                }
                
            }
            
            for percentage in HLLDefaults.notifications.Percentagemilestones {
                
                let secondsFromStart = Int(event.duration)/100*percentage
                let date = event.startDate.addingTimeInterval(TimeInterval(secondsFromStart))
                
                if event.completionStatus(at: date) == .Current {
                
                let content = HLLNotificationContent(date: date)
                content.title = "\(event.truncatedTitle()) is \(percentage)% done."
                content.subtitle = "(\(countdownStringGenerator.generateCountdownTextFor(event: event, currentDate: date, force: .End).justCountdown) left)"
                let upcomingData = getUpcomingEventData(at: date, from: events, exclude: event)
                content.body = upcomingData.string
                content.event = event
                contentItems.append(content)
                    
                }
                
            }
            
        }
        
        return contentItems
        
    }
    
    // MARK: Utils for content generation
    
    func getUpcomingEventData(at date: Date, from events: [HLLEvent], exclude event: HLLEvent) -> (event: HLLEvent?, string: String, startingNow: Bool) {
        
        var returnEvent: HLLEvent?
        var returnString = "Nothing next"
        var returnStartingNow = false
        
        if let nextEvent = eventsNotStartedBy(date: date, events: events, exclude: event).first {
            
            returnEvent = nextEvent
            var locationEvent = nextEvent
            
            returnString = "\(nextEvent.title.truncated(limit: 13)) "
            
            if date == nextEvent.startDate {
                returnString += "is starting now"
                returnStartingNow = true
            } else {
                returnString += "starts next"
            }
            
            if nextEvent.isMagdaleneBreak, events.indices.contains(1) {
                locationEvent = events[1]
                returnString += ", then \(locationEvent.title)"
            }
            
            returnString += "."
            
            if let location = locationEvent.location?.truncated(limit: 13) {
                returnString += " (\(location))"
            }
            
        }
        
        return (returnEvent, returnString, returnStartingNow)
        
    }
    
    func eventsNotStartedBy(date: Date, events: [HLLEvent], exclude: HLLEvent) -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        let sorted = events.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        for event in sorted {
            
            if event.startDate.timeIntervalSince(date) >= 0, event != exclude {
                
                returnArray.append(event)
                
            }
            
        }
        
        return returnArray
    }
    
    func generateEventNotificationUserInfo(for event: HLLEvent) -> [AnyHashable:Any] {
        
        var returnArray = [AnyHashable:Any]()

        returnArray["eventidentifier"] = event.identifier
        
        return returnArray
        
    }
    
}

class HLLEventGroup {
    
    init(_ events: [HLLEvent]) {
        
        self.events = events
    }
    
    var events = [HLLEvent]()
    
    func representativeString() -> String {
        
        let eventsForRepresentation = events
        
        if let first = eventsForRepresentation.first {
        
        if eventsForRepresentation.count == 1 {
            return first.truncatedTitle(20)
        }
            
        let count = eventsForRepresentation.count-1
        return "\(first.truncatedTitle(20)) & \(count) more"
        
        } else {
             return "(No Events)"
        }
        
    }
    
}
