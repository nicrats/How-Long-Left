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

class EventDataSource {
    
    static let shared = EventDataSource()
    
    static var accessToCalendar = calendarAccess.Unknown
    let defaults = UserDefaults(suiteName: "group.com.ryankontos.How-Long-Left")!
    let schoolFunctionsManager = SchoolFunctionsManager()
    let schoolHolidaysManager = MagdaleneSchoolHolidays()
    var latestFetchSchoolMode = SchoolMode.None
    static var eventStore = EKEventStore()
    
    
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
    
    func getEventsFromCalendar(start: Date, end: Date) -> [HLLEvent] {
        
        getCalendarAccess()
        
        
        
        var returnArray = [HLLEvent]()
        
        var calendars = [EKCalendar]()
      //  let allCals = calendars
        
        #if os(iOS) || os(watchOS)
        
        if var storedIDS = defaults.stringArray(forKey: "setCalendars")  {
            
            if storedIDS.isEmpty, defaults.bool(forKey: "userDidTurnOffAllCalendars") == false {
                
                var idArray = [String]()
                
                for calendar in getCalendars() {
                    
                    idArray.append(calendar.calendarIdentifier)
                    
                }
                
                
                defaults.set(idArray, forKey: "setCalendars")
                storedIDS = defaults.stringArray(forKey: "setCalendars")!
            }
            
            
            for id in storedIDS {
                
                for calendar in getCalendars() {
                    
                    if calendar.calendarIdentifier == id {
                        
                        calendars.append(calendar)
                        
                        
                    }
                    
                }
                
                
            }
            
            
        } else {
            
            var idArray = [String]()
            
            for calendar in getCalendars() {
                
                idArray.append(calendar.calendarIdentifier)
                
            }
            
            
            defaults.set(idArray, forKey: "setCalendars")
            
        }
        
        
        
        #elseif os(OSX)
        
        calendars = getCalendars()
        if HLLDefaults.calendar.useAllCalendars != true, let calendar = HLLDefaults.calendar.selectedCalendar {
            
            for item in calendars {
                
                if item.calendarIdentifier != calendar {
                    
                    if let index = calendars.firstIndex(of: item) {
                        
                        calendars.remove(at: index)
                        
                    }
                    
                }
            }
            
        }
        
        
        #endif
        
        #if os(iOS)
        
        
       // let ids = calendars.map { $0.calendarIdentifier }
       // WatchSessionManager.sharedManager.startSession()
       // WatchSessionManager.sharedManager.updateContext(userInfo: ["SelectedCalendars" : ids])
        
      //  let _ = WatchSessionManager.sharedManager.tra
        
        #endif
        
       
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
            
        
        latestFetchSchoolMode = SchoolAnalyser.schoolMode
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
                
            case .Next24Hours:
                
                // Return all calendar events occuring in the next 24 hours.
                
                startDate = Date()
                endDate = startDate!.addingTimeInterval(86400)
                
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
            
        
    
    func getCurrentEvents() -> [HLLEvent] {
        
        // Returns all calendar events that are currently in progress.
        
        let eventsToday = fetchEventsFromPresetPeriod(period: EventFetchPeriod.AllToday)
        
        var currentEvents = [HLLEvent]()

        for event in eventsToday {
            
            let timeUntilStart = event.startDate.timeIntervalSinceNow
            let timeUntilEnd = event.endDate.timeIntervalSinceNow
            
            if timeUntilStart < 1, timeUntilEnd > 0 {
                
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
        
        EventCache.upcomingEventsToday = upcomingEvents
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
        
        EventCache.nextUpcomingEventsDay = returnEvents
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
        
        EventCache.upcomingWeekEvents = returnArray
        return returnArray
        
    }
    
    
    }
