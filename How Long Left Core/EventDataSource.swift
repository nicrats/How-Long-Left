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
 * Methods for interfacing with the calendar.
 */

class EventDataSource {
    
    let queue = DispatchQueue(label: "thread-safe-obj", attributes: .concurrent)
    var events = [HLLEvent]()
    static var accessToCalendar = CalendarAccessState.Unknown
    var latestFetchSchoolMode = SchoolMode.None
    static var eventStore = EKEventStore()
    static var lastUpdatedWithCalendars = [String]()
    static var calendarReads = 0
    var delegate: EventDataSourceDelegate?
    static var isRenaming = false
    
    func updateEventStore() {
        
        if !EventDataSource.isRenaming {
        
        EventDataSource.eventStore.reset()
            
        }
        
    }
       
    
    init() {
        getCalendarAccess()
        
    }
    
    
    init(with aDelegate: EventDataSourceDelegate) {
        
        delegate = aDelegate
        getCalendarAccess()
        
        
    }
    
    
    func getCalendarAccess() {
        
        EventDataSource.eventStore.requestAccess(to: .event, completion:
            
            {
                
                (granted: Bool, NSError) -> Void in
                if granted == true {
                    
                    
                    
                    if EventDataSource.accessToCalendar != .Granted {
                    
                        
                    }
                    
                    
                    EventDataSource.accessToCalendar = .Granted
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    NotificationCenter.default.post(name: Notification.Name("CalendarAllowed"), object: nil)
                        
                    })
                    
                } else {
                    
                    EventDataSource.accessToCalendar = .Denied
                    
                    if let safe = self.delegate {
                        
                        safe.calendarAccessDenied()
                        
                    }
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
        
        var returnArray = [HLLEvent]()
        
        autoreleasepool {
        
        
        let defaults = HLLDefaults.defaults
        let schoolFunctionsManager = SchoolFunctionsManager()
        let schoolHolidaysManager = MagdaleneSchoolHolidays()
        var calendars = [EKCalendar]()
        
        #if os(iOS) || os(watchOS)
        
        if let storedIDS = defaults.stringArray(forKey: "setCalendars") {
            
            for id in storedIDS {
                
                for calendar in self.getCalendars() {
                    
                    if calendar.calendarIdentifier == id {
                        
                        calendars.append(calendar)
                        
                        
                    }
                    
                }
                
                
            }
            
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
            HLLDefaults.calendar.disabledCalendars = [String]()
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
        
        if HLLDefaults.calendar.enabledCalendars.isEmpty == true {
            
             var allArray = [String]()
            
            for calendar in getCalendars() {
                    
                allArray.append(calendar.calendarIdentifier)
                
            }
            
            HLLDefaults.calendar.enabledCalendars = allArray
        }
        
        let disabled = HLLDefaults.calendar.disabledCalendars
        let selected = HLLDefaults.calendar.enabledCalendars
        
        for calendar in getCalendars() {
            
            if selected.contains(calendar.calendarIdentifier) {
                
                calendars.append(calendar)
                
            } else {
                
               if disabled.contains(calendar.calendarIdentifier) == false {
                    
                    calendars.append(calendar)
                    
                }
                
            }
            
            
        }
        
        #endif
        
        if calendars.isEmpty {
            
            calendars.append(contentsOf: getCalendars())
            
            var idArray = [String]()
            
            for calendar in getCalendars() {
                
                if HLLDefaults.calendar.disabledCalendars.contains(calendar.calendarIdentifier) == false {
                
                idArray.append(calendar.calendarIdentifier)
                    
                }
                
            }
            
            HLLDefaults.calendar.enabledCalendars = idArray
            
        
        }
        
        var idArray = [String]()
        
        for cal in calendars {
            
            idArray.append(cal.calendarIdentifier)
            
        }
        
        EventDataSource.lastUpdatedWithCalendars = HLLDefaults.calendar.enabledCalendars
        self.latestFetchSchoolMode = SchoolAnalyser.schoolMode
        
        
        if calendars.isEmpty == true {
            
            
            return
            
        }
        
        
        
        let predicate = EventDataSource.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        
        let EKevents = EventDataSource.eventStore.events(matching: predicate)
        
        
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
    
        
        }
        
        return returnArray
            
        
        
        
    }
    
    func findEventWithIdentifier(id: String) -> HLLEvent? {
        
            
        if let ek = EventDataSource.eventStore.event(withIdentifier: id) {
            
            let manager = SchoolFunctionsManager()
            return manager.handle(events: [HLLEvent(event: ek)]).first
            
        }
        
        return nil
        
        
    }
    
    func fetchEventsOnDay(day: Date) -> [HLLEvent] {
        
        let start = day.midnight()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        return getEventsFromCalendar(start: start, end: end!)
        
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
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate!)
            
        case .UpcomingToday:
            
            // Return all calendar events occuring today that have not already started.
            
            startDate = Date()
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate!)
            
        case .AllTodayPlus24HoursFromNow:
            
            // Return all calendar events occuring in the next 24 hours.
            
            startDate = NSCalendar.current.date(from: comp)!
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate!)
            
        case .Next2Weeks:
            
            startDate = NSCalendar.current.date(from: comp)!
            endDate = Calendar.current.date(byAdding: .day, value: 14, to: startDate!)
            
            
        case .AnalysisPeriod:
            
            // Return all calendar events from 2 days ago to 2 days from now.
            
            startDate = NSCalendar.current.date(from: comp)!.addingTimeInterval(-604800)
            endDate = NSCalendar.current.date(from: comp)!.addingTimeInterval(604800)
            
        case .ThisYear:
            
            startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: Date())))!
            
            endDate = Calendar.current.date(byAdding: DateComponents(year: 1), to: startDate!)!
            
            
            
        case .OneMonthEachSideOfToday:
            
            startDate = NSCalendar.current.date(from: comp)!.addingTimeInterval(-2592000)
            endDate = NSCalendar.current.date(from: comp)!.addingTimeInterval(2592000)
            
        }
        
        
        return getEventsFromCalendar(start: startDate!, end: endDate!)
        
    }
    
    func getCurrentEvent() -> HLLEvent? {
        
        return getCurrentEvents().first
        
    }
    
    
    let getCurrentEventsQueue = DispatchQueue(label: "getCurrentEvents")
    
    func getCurrentEvents() -> [HLLEvent] {
        
        let startDate = Date().midnight()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        
        let eventsToday = getEventsFromCalendar(start: startDate, end: endDate!)
        
        var currentEvents = [HLLEvent]()
        
        for event in eventsToday {
            
            if event.startDate.timeIntervalSinceNow < 1, event.endDate.timeIntervalSinceNow > 0 {
                
                currentEvents.append(event)
                
            }
        }
        
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        return currentEvents
    }
    
    func getUpcomingEventsToday() -> [HLLEvent] {
        
        let eventsToday = fetchEventsFromPresetPeriod(period: EventFetchPeriod.AllToday)
        
        var upcomingEvents = [HLLEvent]()
        
        for event in eventsToday {
            
            if event.startDate.timeIntervalSinceNow > 0 {
                
                upcomingEvents.append(event)
                
            }
        }
        
        return upcomingEvents.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
    }
    
    func getUpcomingEventsFromNextDayWithEvents(includeStarted: Bool = false) -> ([HLLEvent]) {
        
        var upEvents = [HLLEvent]()
        var returnEvents = [HLLEvent]()
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        var loopStart = NSCalendar.current.date(from: comp)!
        var loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)
        
        outer: for _ in 1...7 {
            
            upEvents = getEventsFromCalendar(start: loopStart, end: loopEnd!)
            var notStarted = [HLLEvent]()
            
            for event in upEvents {
                
                if event.startDate.timeIntervalSinceNow > 0 || includeStarted == true {
                    
                    notStarted.append(event)
                    
                }
            }
            
            if notStarted.isEmpty == false {
                returnEvents = notStarted
                break outer
            }
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: loopStart)
            comp.timeZone = TimeZone.current
            loopStart = NSCalendar.current.date(from: comp)!
            loopStart = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)!
            loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopEnd!)
            
        }
        
        return returnEvents.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
    }
    
    func getArraysOfUpcomingEventsForNextSevenDays(includeAllToday: Bool = true) -> [Date:[HLLEvent]] {
        
        var returnArray = [Date:[HLLEvent]]()
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        var loopStart = NSCalendar.current.date(from: comp)!
        var loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)
        
        for _ in 1...8 {
            
            var events = getEventsFromCalendar(start: loopStart, end: loopEnd!).sorted(by: {
                $0.startDate.compare($1.startDate) == .orderedAscending })
            
            for event in events {
                
                if event.startDate.midnight() != loopStart.midnight() || event.startDate.timeIntervalSinceNow < 0 {
                    
                    let index = events.firstIndex(of: event)!
                    events.remove(at: index)
                    
                }
                
            }
            
            
            returnArray[loopStart] = events
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: loopStart)
            comp.timeZone = TimeZone.current
            loopStart = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)!
            loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopEnd!)
            
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

protocol EventDataSourceDelegate {
    func calendarAccessDenied()
}
