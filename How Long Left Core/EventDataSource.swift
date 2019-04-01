//
//  EventDataSource.swift
//  How Long Left
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//
//  Retreives data from the calendar.
//

import Foundation
import EventKit

/**
 * Methods for fetching user events.
 */

class EventDataSource {
    
    static let shared = EventDataSource()
    //let eFetchQueue = DispatchQueue(label: "fetchQueue")
    
    static var accessToCalendar = calendarAccess.Unknown
    var latestFetchSchoolMode = SchoolMode.None
    static var eventStore = EKEventStore()
    static var lastUpdatedWithCalendars = [String]()
    //static var schoolCheckDone = false
    
    static var calendarReads = 0
    
    func updateEventStore() {
        EventDataSource.eventStore = EKEventStore()
        
            
        
            
        
        
    }
    
    init() {
        getCalendarAccess()
       // CalendarData.receivedStoredCalendars = getCalendars()
        
    }
    
    
    
    func getCalendarAccess() {
        
        EventDataSource.eventStore.requestAccess(to: .event, completion:
            
            { (granted: Bool, NSError) -> Void in
            if granted == true {
                
                EventDataSource.accessToCalendar = .Granted
                
                
            } else {
                
                EventDataSource.accessToCalendar = .Denied
                
            }
        
        })
        
    }
    
    func getCalendars() -> [EKCalendar] {
        return EventDataSource.eventStore.calendars(for: .event)
    }
    
    
    func getCalendarIDS() -> [String] {
        return EventDataSource.eventStore.calendars(for: .event).map { $0.calendarIdentifier }
    }
    
    func getEventsFromCalendar(start: Date, end: Date) -> [HLLEvent] {
        
        EventDataSource.calendarReads += 1
        
       // print("Doing calendar read \(EventDataSource.calendarReads)")
        
        var returnArray = [HLLEvent]()
            
           // print("Getting events")
            
            
            
            self.getCalendarAccess()
            
            let defaults = HLLDefaults.defaults
            let schoolFunctionsManager = SchoolFunctionsManager()
            let schoolHolidaysManager = MagdaleneSchoolHolidays()
            
            
            var calendars = [EKCalendar]()
            //  let allCals = calendars
            
            #if os(iOS) || os(watchOS)
        
            
            if let storedIDS = defaults.stringArray(forKey: "setCalendars") {
                
             //   print("Stored IDs count: \(storedIDS.count)")
                
                for id in storedIDS {
                    
                    for calendar in self.getCalendars() {
                        
                        if calendar.calendarIdentifier == id {
                            
                            calendars.append(calendar)
                            
                            
                        }
                        
                    }
                    
                    
                }
                
                //    print("Reading cal with \(calendars.count) calendars")
                
                
            }
        
        if calendars.isEmpty == true {
            
            for calendar in getCalendars() {
                
                calendars.append(calendar)
                
                
                
                
            }
            
            
        }
        
        HLLDefaults.calendar.enabledCalendars = calendars.map { $0.calendarIdentifier }
            
            
            #elseif os(OSX)
            
            if HLLDefaults.calendar.useAllCalendars == true, EventDataSource.accessToCalendar == .Granted {
                
                
                var idArray = [String]()
                
                for calendar in getCalendars() {
                    
                    idArray.append(calendar.calendarIdentifier)
                    
                }
                
                HLLDefaults.calendar.enabledCalendars = idArray
                HLLDefaults.calendar.useAllCalendars = false
                
            } else if let oldCal = HLLDefaults.calendar.selectedCalendar {
                
                HLLDefaults.defaults.set(nil, forKey: "selectedCalendar")
                
                var idArray = [String]()
                
                for calendar in getCalendars() {
                    
                    if calendar.calendarIdentifier == oldCal {
                        
                        idArray.append(calendar.calendarIdentifier)
                        
                    }
                    
                }
                
                HLLDefaults.calendar.enabledCalendars = idArray
                
                
            }
            
            
            let selected = HLLDefaults.calendar.enabledCalendars
            
            for calendar in getCalendars() {
                
                if selected.contains(calendar.calendarIdentifier) {
                    
                    calendars.append(calendar)
                    
                }
                
                
            }
            
            
            
            /*      calendars = self.getCalendars()
             if HLLDefaults.calendar.useAllCalendars != true, let calendar = HLLDefaults.calendar.selectedCalendar {
             
             for item in calendars {
             
             if item.calendarIdentifier != calendar {
             
             if let index = calendars.firstIndex(of: item) {
             
             calendars.remove(at: index)
             
             }
             
             }
             }
             
             } */
            
            
            #endif
        
            
            var idArray = [String]()
            
            for cal in calendars {
                
                idArray.append(cal.calendarIdentifier)
                
            }
            
            EventDataSource.lastUpdatedWithCalendars = HLLDefaults.calendar.enabledCalendars
            self.latestFetchSchoolMode = SchoolAnalyser.schoolMode
        
        
            if calendars.isEmpty == true {
                
                
                return returnArray
                
            }
            
            
            
            let predicate = EventDataSource.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
            
            let EKevents = EventDataSource.eventStore.events(matching: predicate)
            
            /*   var hashableArray = EKevents.map { $0.title }
             hashableArray.append(contentsOf: EKevents.map { $0.startDate.formattedTime() })
             hashableArray.append(contentsOf: EKevents.map { $0.endDate.formattedTime() }) */
            
            //  print("Events hash is \(hashableArray.hashValue)")
            
            for event in EKevents {
                
                if event.isAllDay == false {
                    
                    returnArray.append(HLLEvent(event: event))
                    
                }
            }
            
            
            returnArray = schoolFunctionsManager.handle(events: returnArray)
            
            if let holidays = schoolHolidaysManager.getSchoolHolidaysFrom(start: start, end: end) {
                returnArray.append(holidays)
            }
            
            returnArray.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
            
            
        
            
       return returnArray
        
            
    }
    
    func fetchEventsOnDay(day: Date) -> [HLLEvent] {
        
        let start = day.midnight()
        let end = start.addingTimeInterval(86400)
        return getEventsFromCalendar(start: start, end: end)
        
    }
    
    func fetchEventsOnDays(days: [Date]) -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        for day in days {
            
            returnArray.append(contentsOf: fetchEventsOnDay(day: day))
            
        }
        
        returnArray.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        return returnArray
        
    }
    
    
    func fetchEventsFromPresetPeriod(period: EventFetchPeriod) -> [HLLEvent] {
        
        // Returns an array of all calendar events occuring in the specified period.
        
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
            comp.timeZone = TimeZone.current
            
            var startDate: Date?
            var endDate: Date?
            
            switch period {
            case .AllToday:
                
                // Return all calendar events occuring today.
                
                startDate = NSCalendar.current.date(from: comp)!
                endDate = startDate!.addingTimeInterval(86400)
                
            case .UpcomingToday:
                
                // Return all calendar events occuring today that have not already started.
                
                startDate = Date()
                endDate = NSCalendar.current.date(from: comp)?.addingTimeInterval(86400)
                
            case .AllTodayPlus24HoursFromNow:
                
                // Return all calendar events occuring in the next 24 hours.
                
                startDate = NSCalendar.current.date(from: comp)!
                endDate = Date().addingTimeInterval(86400)
                
            case .Next2Weeks:
                
                startDate = NSCalendar.current.date(from: comp)!
                endDate = startDate!.addingTimeInterval(1209600)
            
                
            case .AnalysisPeriod:
                
                // Return all calendar events from 2 days ago to 2 days from now.
                
                startDate = NSCalendar.current.date(from: comp)!.addingTimeInterval(-604800)
                endDate = NSCalendar.current.date(from: comp)!.addingTimeInterval(604800)
                
            case .ThisYear:
                
                startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: Date())))!
                
                endDate = Calendar.current.date(byAdding: DateComponents(year: 1), to: startDate!)!
                
                
                
        }
            
        
        return getEventsFromCalendar(start: startDate!, end: endDate!)
        
    }
    
    func getCurrentEvent() -> HLLEvent? {
        
        // Returns the calendar event that is currently in progress. If there are multiple, returns the one that is closest to finishing.
        
         return getCurrentEvents().first
        
    }
            
        
    let getCurrentEventsQueue = DispatchQueue(label: "getCurrentEvents")
    
    func getCurrentEvents() -> [HLLEvent] {
        
        
        // Returns all calendar events that are currently in progress.
        
        let eventsToday = fetchEventsFromPresetPeriod(period: EventFetchPeriod.AllToday)
        
        var currentEvents = [HLLEvent]()

        for event in eventsToday {
            
            if event.startDate.timeIntervalSinceNow < 1, event.endDate.timeIntervalSinceNow > 0 {
                
                currentEvents.append(event)
                
            }
        }
        
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        EventCache.currentEvents = currentEvents
        
        return currentEvents
    }
    
    func getUpcomingEventsToday() -> [HLLEvent] {
        
        // Returns the events today that have not yet started.
        
        let eventsToday = fetchEventsFromPresetPeriod(period: EventFetchPeriod.AllToday)
        
        var upcomingEvents = [HLLEvent]()
        
        for event in eventsToday {
            
            if event.startDate.timeIntervalSinceNow > 0 {
                
                upcomingEvents.append(event)
                
            }
        }
        
        return upcomingEvents
    }
    
    func getUpcomingEventsFromNextDayWithEvents() -> ([HLLEvent]) {
        
        var upEvents = [HLLEvent]()
        var returnEvents = [HLLEvent]()
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        var loopStart = NSCalendar.current.date(from: comp)!
        var loopEnd = loopStart.addingTimeInterval(86400)
        
        outer: for _ in 1...7 {
            
            upEvents = getEventsFromCalendar(start: loopStart, end: loopEnd)
            var notStarted = [HLLEvent]()
            
            for event in upEvents {
                
                if event.startDate.timeIntervalSinceNow > 0 {
                    
                   notStarted.append(event)
                    
                }
        }
            
            if notStarted.isEmpty == false {
                returnEvents = notStarted
                break outer
            }
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: loopStart)
            comp.timeZone = TimeZone.current
            loopStart = NSCalendar.current.date(from: comp)!.addingTimeInterval(86400)
            loopEnd = loopEnd.addingTimeInterval(86400)
            
        }
        
        return returnEvents
        
    }
    
    func getArraysOfUpcomingEventsForNextSevenDays() -> [Date:[HLLEvent]] {
        
        var returnArray = [Date:[HLLEvent]]()
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        var loopStart = NSCalendar.current.date(from: comp)!
        var loopEnd = loopStart.addingTimeInterval(86400)
        
        for _ in 1...8 {
            
            returnArray[loopStart] = getEventsFromCalendar(start: loopStart, end: loopEnd)
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: loopStart)
            comp.timeZone = TimeZone.current
            loopStart = NSCalendar.current.date(from: comp)!.addingTimeInterval(86400)
            loopEnd = loopEnd.addingTimeInterval(86400)
            
        }
        
        return returnArray
        
    }
    
    func calendarFromID(_ id: String?) -> EKCalendar? {
        
        if let safeId = id {
        
        return EventDataSource.eventStore.calendar(withIdentifier: safeId)
            
        }
        
        return nil
        
    }
    
    
    }
