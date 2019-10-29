//
//  HLLEventSource.swift
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
 * Methods for retriving HLLEvents/
 */

class HLLEventSource {
    
    static var shared = HLLEventSource()
    
    static var accessToCalendar = CalendarAccessState.Unknown
    var access = CalendarAccessState.Unknown
    var eventStore = EKEventStore()
    
    var eventPool = [HLLEvent]()
    var eventPoolObservers = [EventPoolUpdateObserver]()

    var addBreaks = true
    var latestFetchSchoolMode = SchoolMode.None
    var enabledCalendars = [EKCalendar]()
    var lastUpdatedWithCalendars = [String]()
    static var isRenaming = false
    var neverUpdatedEventPool = true
    
    let schoolAnalyser = SchoolAnalyser()
    let magdaleneBreaks = MagdaleneBreaks()
    let schoolEventModifier = SchoolEventModifier()
    let schoolHolidaysFetcher = SchoolHolidayEventFetcher()
    let termFetcher = TermEventFetcher()
    
    var eventPoolUpdateTimer: Timer?
    var eventPoolUpdateRequestedDuringCooldown = false
    
    /*func updateEventStore() {
        if !self.isRenaming {
        
        self.eventStore.reset()
            
        }
    } */
       
    
    init() {
        
        print("Init EDS 1")
        
        getCalendarAccess()
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.asyncUpdateEventPool),
        name: .EKEventStoreChanged,
        object: nil)
    }
    
    func getCalendarAccess() {
        
            self.eventStore.requestAccess(to: .event, completion: { (granted: Bool, NSError) -> Void in
                
                let prevState = self.access
                
                print("CADB: Prevstate was \(prevState)")
                
                if granted == true {
                    print("CADB: Granted")
                    HLLEventSource.accessToCalendar = .Granted
                    self.access = .Granted
                } else {
                    print("CADB: Denied")
                    HLLEventSource.accessToCalendar = .Denied
                    self.access = .Denied
                }
                
                DispatchQueue.global(qos: .userInteractive).async {
                    if self.access != prevState {
                        self.updateEventPool(quick: true)
                        print("PoolC2")
                    }
                }
                
            })
        
    }
    
    @objc func asyncUpdateEventPool() {
        
        if HLLEventSource.isRenaming == false {
        
        DispatchQueue.global(qos: .default).async {
        
            print("Async pool update")
            
            
                self.updateEventPool()
                print("PoolC3")
            }
            
            
        }
        
    }
    
    func updateEventPool(quick: Bool = false) {
        
        if access != .Granted {
            return
        }
        
        #if os(watchOS)
            let days = 7
        #else
            let days = 14
        #endif
        
        let previous = self.eventPool
        
        var analysisEvents = [HLLEvent]()
        
        let start = Date().startOfDay()
        let end = Calendar.current.date(byAdding: .day, value: days, to: start)!
        
        var add = self.getEventsFromCalendar(start: start, end: end)
        
        analysisEvents.append(contentsOf: add)
        
        #if !os(watchOS)
               
            for date in SchoolAnalyser.termDates {
                   
                analysisEvents.append(contentsOf: self.getEventsFromCalendar(start: date.startOfDay().addingTimeInterval(29640), end: date.startOfDay().addingTimeInterval(52560)))
                   
            }
               
        #endif
            
        schoolAnalyser.analyseCalendar(inputEvents: analysisEvents)
        
        if SchoolAnalyser.schoolMode == .Magdalene {
        
        add = schoolEventModifier.modify(events: add, addBreaks: addBreaks)
            
        if let holidays = schoolHolidaysFetcher.getSchoolHolidaysFrom(start: start, end: end), HLLDefaults.magdalene.doHolidays {
            add.append(holidays)
        }
        
        if let term = termFetcher.getCurrentTermEvent(), HLLDefaults.magdalene.doTerm {
            add.append(term)
        }
        
        }
       
        FollowingOccurenceStore.shared.updateNextOccurenceDictionary(events: add)
        self.eventPool = add
        self.neverUpdatedEventPool = false
        eventPoolObservers.forEach { $0.eventPoolUpdated() }
        
        if self.eventPool != previous || previous.isEmpty {
            
            
            
        }
        print("Updated event pool with \(self.eventPool.count) events")
        
        if quick {
            
            DispatchQueue.global(qos: .default).async {
                
                self.updateEventPool()
                
            }
            
        }
        
    }
    
    @objc func eventPoolCooldownEnded() {
        
        eventPoolUpdateTimer?.invalidate()
        eventPoolUpdateTimer = nil
        
        if eventPoolUpdateRequestedDuringCooldown {
            updateEventPool()
        }
        
        eventPoolUpdateRequestedDuringCooldown = false
        
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    
    func getCalendarIDS() -> [String] {
        return getCalendars().map { $0.calendarIdentifier }
        
    }
    
    func getEventsFromEventPool(start: Date, end: Date, includeHidden: Bool = false) -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        if neverUpdatedEventPool {
            
            return returnArray
            
        }
        
        let poolEvents = eventPool
        
        for event in poolEvents {
            
            if event.startDate.timeIntervalSince(end) < 0, event.endDate.timeIntervalSince(start) > 0 {
                
                if event.isHidden {
                    
                    if !includeHidden {
                        
                        continue
                        
                    }
                    
                }
                
                if event.isAllDay {
                    
                    if !HLLDefaults.general.showAllDay {
                        
                        continue
                        
                    }
                    
                }
                
                returnArray.append(event)
                
            }
            
            
        }
        
        
        returnArray.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        return returnArray
        
    }
    
    let readQueue = DispatchQueue(label: "readQueue")
    
    func getEventsFromCalendar(start: Date, end: Date) -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        readQueue.sync {
        
        if HLLDefaults.calendar.enabledCalendars.isEmpty, HLLDefaults.calendar.disabledCalendars.isEmpty {
            HLLDefaults.calendar.enabledCalendars = getCalendarIDS()
        }
        
        let enabledIDS = HLLDefaults.calendar.enabledCalendars
        let allCalendars = getCalendars()
            
        var calendars = [EKCalendar]()
        var disabledCalendars = [EKCalendar]()
        
        for calendar in allCalendars {
            
            if enabledIDS.contains(calendar.calendarIdentifier) {
                
                calendars.append(calendar)
                
            } else if HLLDefaults.calendar.useNewCalendars, !HLLDefaults.calendar.disabledCalendars.contains(calendar.calendarIdentifier) {
                
                calendars.append(calendar)

            } else {
                
                disabledCalendars.append(calendar)
            }
                
            
        }
        
        HLLDefaults.calendar.enabledCalendars = calendars.map {$0.calendarIdentifier}
        HLLDefaults.calendar.disabledCalendars = disabledCalendars.map {$0.calendarIdentifier}
        
        var calendarEvents = [EKEvent]()
        
        let predicate = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        calendarEvents = self.eventStore.events(matching: predicate)

        for event in calendarEvents {
            returnArray.append(HLLEvent(event: event))
        }
        
        }
        
        return returnArray
    }
    
    func findEventWithIdentifier(id: String) -> HLLEvent? {
        
        if let event = eventPool.first(where: {$0.identifier == id}) {
            
            return event
            
        } else {
            
            return eventPool.first(where: {$0.EKEvent?.eventIdentifier == id})
        }

        
    }
    
    func findEventWithAppIdentifier(id: String) -> HLLEvent? {
        
        return eventPool.first(where: {$0.identifier == id})

        
    }
    
    func fetchEventsOnDay(day: Date) -> [HLLEvent] {
        
        let start = day.startOfDay()
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
        
        
        return getEventsFromEventPool(start: startDate!, end: endDate!)
        
    }
    
    func getCurrentEvent() -> HLLEvent? {
        
        return getCurrentEvents().first
        
    }
    
    
    let getCurrentEventsQueue = DispatchQueue(label: "getCurrentEvents")
    
    func getCurrentEvents(includeHidden: Bool = false) -> [HLLEvent] {
        
        let startDate = Date().startOfDay()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        
        let eventsToday = getEventsFromEventPool(start: startDate, end: endDate!, includeHidden: includeHidden)
        
        var currentEvents = [HLLEvent]()
        
        for event in eventsToday {
            
            if event.startDate.timeIntervalSinceNow < 1, event.endDate.timeIntervalSinceNow > 0 {
                
                currentEvents.append(event)
                
            }
        }
        
        
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        return currentEvents
    }
    
    func getNextUpcomingEvent() -> HLLEvent? {
        
        return getUpcomingEventsFromNextDayWithEvents().first
        
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
    
    func getCurrentAndUpcomingTodayOrdered() -> [HLLEvent] {
        
        var events = [HLLEvent]()
        
        events.append(contentsOf: getCurrentEvents(includeHidden: true))
        events.append(contentsOf: getUpcomingEventsFromNextDayWithEvents(includeStarted: false))
        
        return events.sorted(by: { $0.countdownDate.compare($1.countdownDate) == .orderedAscending })
        
        
    }

    func getUpcomingEventsFromNextDayWithEvents(includeStarted: Bool = false) -> [HLLEvent] {
        
        var upEvents = [HLLEvent]()
        var returnEvents = [HLLEvent]()
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        var loopStart = NSCalendar.current.date(from: comp)!
        var loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)
        
        outer: for _ in 1...7 {
            
            upEvents = getEventsFromEventPool(start: loopStart, end: loopEnd!)
            var notStarted = [HLLEvent]()
            
            for event in upEvents {
                
                if event.startDate.timeIntervalSinceNow > 0 || includeStarted == true, event.startDate.startOfDay() == loopStart.startOfDay() {
                    
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
    
    func getArraysOfUpcomingEventsForNextSevenDays(returnEmptyItems: Bool) -> [DateOfEvents] {
        
        var returnArray = [DateOfEvents]()
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        
        var loopStart = Date().startOfDay()
        
        var loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)!.startOfDay()
        
        for _ in 1...8 {
            
            var events = getEventsFromEventPool(start: loopStart, end: loopEnd).sorted(by: {
                $0.startDate.compare($1.startDate) == .orderedAscending })
            
            events.removeAll { $0.completionStatus != .Upcoming }
            events.removeAll { $0.startDate.startOfDay() != loopStart.startOfDay() }
            
            if events.isEmpty {
                
                if returnEmptyItems {
                    
                  returnArray.append(DateOfEvents(date: loopStart, events: events))
                    
                }
                
                
            } else {
                
                returnArray.append(DateOfEvents(date: loopStart, events: events))
                
            }
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: loopStart)
            comp.timeZone = TimeZone.current
            loopStart = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)!
            loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopEnd)!
            
        }
        
        
        returnArray.sort(by: {
            
            $0.date.compare($1.date) == .orderedAscending
            
        })
        
        return returnArray
        
    }
    
    func calendarFromID(_ id: String?) -> EKCalendar? {
        
        if let safeId = id {
            
            return self.eventStore.calendar(withIdentifier: safeId)
            
        }
        
        return nil
        
    }
    
    func addEventPoolObserver(_ observer: EventPoolUpdateObserver) {
        
        self.eventPoolObservers.append(observer)
            
        if neverUpdatedEventPool == false {
            observer.eventPoolUpdated()
        }
            
        
        
    }
    
}

protocol CalendarAccessStateDelegate {
    func calendarAccessDenied()
}


protocol EventPoolUpdateObserver {
    
    func eventPoolUpdated()
    
}
