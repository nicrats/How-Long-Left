//
//  HLLEventSource.swift
//  How Long Left
//
//  Created by Ryan Kontos on 15/10/18.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
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
    let schoolEventFetcher = SchoolEventFetcher()
    
    var eventPoolUpdateTimer: Timer!
    var eventPoolUpdateRequestedDuringCooldown = false

   
    
    
    init() {
        
        eventPoolUpdateTimer = Timer(timeInterval: 240, target: self, selector: #selector(asyncUpdateEventPool), userInfo: nil, repeats: true)
        
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
                
                //print("CADB: Prevstate was \(prevState)")
                
                if granted == true {
                    //print("CADB: Granted")
                    HLLEventSource.accessToCalendar = .Granted
                    self.access = .Granted
                } else {
                    //print("CADB: Denied")
                    HLLEventSource.accessToCalendar = .Denied
                    self.access = .Denied
                }
                
                DispatchQueue.main.async {
                    if self.access != prevState {
                        self.updateEventPool(quick: true)
                    }
                }
                
            })
        
    }
    
    @objc func asyncUpdateEventPool() {
        
        
        DispatchQueue.global(qos: .default).async {
        
            print("Async pool update")
            
                self.updateEventPool()
                print("PoolC3")
            }
            
            
    
        
    }
    
    static var updatingEventPool = false
    var goingToDoCatchupUpdate = false
    
    func doCatchupEventPoolUpdate() {
        
        goingToDoCatchupUpdate = false
        updateEventPool(catchup: true)
        
    }
    
    func updateEventPool(quick: Bool = false, catchup: Bool = false) {
        
        if access != .Granted {
            return
        }
        
        let eventPoolUpdateStart = Date()
        
        if neverUpdatedEventPool == false {
        
            if HLLEventSource.updatingEventPool {
            
            if goingToDoCatchupUpdate == false, catchup == false {
                
                goingToDoCatchupUpdate = true
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    
                    self.doCatchupEventPoolUpdate()
                    
                }
                
            }
            
            return
            
        }
            
        }
        
        HLLEventSource.updatingEventPool = true
              
        
        #if os(watchOS)
            let days = 7
        #else
            let days = 15
        #endif
        
        if neverUpdatedEventPool == false {
        
        self.eventStore.reset()
            
        }
        var analysisEvents = [HLLEvent]()
        
        let start = Date()-500
        let end = Calendar.current.date(byAdding: .day, value: days, to: start)!
        
        var add = self.getEventsFromCalendar(start: start, end: end)
        add = add.filter({ $0.title != "Staff Development Day" })
        
        
        analysisEvents.append(contentsOf: add)
               
        for date in SchoolAnalyser.termDates {
                   
            analysisEvents.append(contentsOf: self.getEventsFromCalendar(start: date.startOfDay().addingTimeInterval(29640), end: date.startOfDay().addingTimeInterval(52560)))
                   
        }
           
        schoolAnalyser.analyseCalendar(inputEvents: analysisEvents)
        
        if SchoolAnalyser.schoolMode == .Magdalene {
        
        #if os(macOS)

        var indexBuilderEvents = getEventsFromCalendar(start: Date().addingTimeInterval(0-(28*86400)), end: Date().addingTimeInterval(28*86400))
        indexBuilderEvents.append(contentsOf: add)
        SchoolEventDetailIndexBuilder.shared.buildIndexFrom(events: indexBuilderEvents)
            
        #endif
            
        EventLocationIndexer.shared.indexLocations(for: add)
            
        add = schoolEventModifier.modify(events: add, addBreaks: addBreaks)
            
        if HLLDefaults.magdalene.doHolidays {
            add.append(contentsOf: schoolHolidaysFetcher.getHolidays())
        }
        
        if let term = termFetcher.getCurrentTermEvent(), HLLDefaults.magdalene.doTerm {
            add.append(term)
        }
            
        /*if let school = schoolEventFetcher.getSchoolEvent() {
            add.append(school)
        } */
        
        }
        
        
        FollowingOccurenceStore.shared.updateNextOccurenceDictionary(events: add)
        self.eventPool = add
        self.neverUpdatedEventPool = false
        
        if HLLDefaults.calendar.enabledCalendars.count == 0 {
            self.eventPool.removeAll()
        }
        
        self.eventPoolObservers.forEach { observer in
                
            DispatchQueue.global(qos: .default).async {
                
                observer.eventPoolUpdated()
            }
                
        }
        
        HLLEventSource.updatingEventPool = false
        print("Updated event pool with \(self.eventPool.count) events, in \(Date().timeIntervalSince(eventPoolUpdateStart))s")

    }
    
    @objc func eventPoolCooldownEnded() {
        
       
        
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

            if HLLDefaults.general.showAllDay == false {
                calendarEvents = calendarEvents.filter { !$0.isAllDay }
            }
            
        for event in calendarEvents {
            
            returnArray.append(HLLEvent(event: event))
        }
        
        }
        
        if HLLDefaults.calendar.enabledCalendars.isEmpty, !HLLDefaults.calendar.disabledCalendars.isEmpty {
            returnArray.removeAll()
        }
        
        return returnArray
    }
    
    func findEventWithIdentifier(id: String) -> HLLEvent? {
    
        if let event = eventPool.first(where: {
            
            
            return $0.identifier == id}) {

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
            
            startDate = Date().startOfDay()
            endDate = startDate?.addingTimeInterval(86400)
            
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
    
    func getPrimaryEvent(excludeAllDay: Bool = false) -> HLLEvent? {
                
        if let selected = SelectedEventManager.shared.selectedEvent {
            return selected
        }
        
        var event: HLLEvent?
        
        if event == nil, HLLDefaults.statusItem.showCurrent {
            event = getCurrentEvents(includeHidden: false, blockAllDay: true).first
        }
                
        if event == nil, HLLDefaults.statusItem.showUpcoming {
            event = getUpcomingEventsFromNextDayWithEvents(blockAllDay: true).first
        }
        
        if excludeAllDay, let upwrappedEvent = event, upwrappedEvent.isAllDay {
            event = nil
        }
        
        return event
        
    }
    
    func getCurrentEvent() -> HLLEvent? {
        
        return getCurrentEvents().first
        
    }
    
    
    let getCurrentEventsQueue = DispatchQueue(label: "getCurrentEvents")
    
    func getCurrentEvents(includeHidden: Bool = false, blockAllDay: Bool = false) -> [HLLEvent] {
        
        var currentEvents = [HLLEvent]()
        
        for event in self.eventPool {
            
            if event.completionStatus == .Current && (!event.isHidden || includeHidden)  {
                
                if event.isAllDay, blockAllDay {
                    continue
                }
                
                #if os(OSX)
                
                currentEvents.append(event)
                
                #else
                
                if !event.isAllDay || (HLLDefaults.general.showAllDayAsCurrent && event.isAllDay) {
                
                currentEvents.append(event)
                    
                }
                
                #endif
                
            }
        }
        
        
        
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        return currentEvents
    }
    
    func getRecentlyEndedEvents() -> [HLLEvent] {
        
        let events = eventPool.filter { $0.completionStatus == .Done && $0.endDate.timeIntervalSinceNow > -300 }
        return events.sorted(by: { $0.endDate.compare($1.endDate) == .orderedDescending })
        
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
    
    func getTimeline(includeRecentlyEnded: Bool = false, includeUpcoming: Bool = true, chronological: Bool = true) -> [HLLEvent] {
        
        var events = [HLLEvent]()
        
        if includeRecentlyEnded {
        events.append(contentsOf: getRecentlyEndedEvents())
        }
        
        events.append(contentsOf: getCurrentEvents(includeHidden: true))
        
        if includeUpcoming {
        events.append(contentsOf: getUpcomingEventsFromNextDayWithEvents(includeStarted: false))
        }
         
        if chronological {
        events.sort(by: { $0.countdownDate.compare($1.countdownDate) == .orderedAscending })
        }
        
        return events
        
    }

    func getUpcomingEventsFromNextDayWithEvents(includeStarted: Bool = false, blockAllDay: Bool = false) -> [HLLEvent] {
        
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
        
        if blockAllDay {
            returnEvents = returnEvents.filter({!$0.isAllDay})
        }
        
        return returnEvents.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
    }
    
    func getArraysOfUpcomingEventsForNextSevenDays(returnEmptyItems: Bool) -> [DateOfEvents] {
        
        var returnArray = [DateOfEvents]()
        var foundEvents = false
        
        
        var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone.current
        
        var loopStart = Date().startOfDay()
        
        var loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)!.startOfDay()
        
        for _ in 1...8 {
            
            var events = getEventsFromEventPool(start: loopStart, end: loopEnd).sorted(by: {
                $0.startDate.compare($1.startDate) == .orderedAscending })
            
            events.removeAll { $0.completionStatus(at: loopStart) != .Upcoming }
            events.removeAll { $0.startDate.startOfDay() != loopStart.startOfDay() }
            
            
            if events.isEmpty {
                
                if returnEmptyItems {
                    
                  returnArray.append(DateOfEvents(date: loopStart, events: events))
                    
                }
                
                
            } else {
                
                returnArray.append(DateOfEvents(date: loopStart, events: events))
                foundEvents = true
            }
            
            var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: loopStart)
            comp.timeZone = TimeZone.current
            loopStart = Calendar.current.date(byAdding: .day, value: 1, to: loopStart)!
            loopEnd = Calendar.current.date(byAdding: .day, value: 1, to: loopEnd)!
            
        }
        
        
        returnArray.sort(by: {
            
            $0.date.compare($1.date) == .orderedAscending
            
        })
        
        if foundEvents == false {
            returnArray.removeAll()
        }
        
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
        
       // print("There are now \(self.eventPoolObservers.count) evnent pool update observers.")
        
        DispatchQueue.main.async {
        
        if HLLEventSource.shared.neverUpdatedEventPool == false {
        observer.eventPoolUpdated()
        }
            
        }
        
    }
    
}

protocol CalendarAccessStateDelegate {
    func calendarAccessDenied()
}


protocol EventPoolUpdateObserver {
    
    func eventPoolUpdated()
    
}
