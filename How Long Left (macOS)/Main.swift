//
//  Main.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 30/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//
import Foundation
import HotKey
import AppKit
import HLLHelper
import os.log

class Main: HLLCountdownController {
    
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Main")
    let updateInterval = 5
    let fastUpdateInterval = 0.5
    let minUpdateInterval = 0.5
    let statusItemTimerQueue = DispatchQueue(label: "statusItemTimer")
    let mainRunQueue = DispatchQueue(label: "mainRunQueue")
    let frequentLowUsageQueue = DispatchQueue(label: "frequentLowUsage")
    let calUpdateQueue = DispatchQueue(label: "calendarUpdate")
    let schoolHoliday = MagdaleneSchoolHolidays()
    let calendar = NSCalendar.current
    let version = Version()
    var statusItemLoops = 1
    var nextEventToStart: HLLEvent?
    var betaExpiryDate: Date?
    var welcomeWindowController : NSWindowController?
    var welcomeStoryboard = NSStoryboard()
    var mainTimer: Timer?
    var calUpdateCooldownTimer: Timer?
    var dataUpdateTimer: Timer!
    var frequentLowUsageTimer: Timer!
    var checkForUpdateTimer: Timer!
    var lastCalendarUpdate: Date?
    var eventEndUpdateInProgress = false
    var calendarUpdateInProgress = false
    var beenTooLongWithoutUpdate = false
    var updatingStatusItemTimer = false
    var fastTimerMode = false
    var statusItemTimerRunning = false
    var inCalendarUpdateCooldown = false
    var updateRequestedDuringCooldown = false
    var shownUpdateNotification = false
    var shownNoCalAccessNotification = false
    var shownBetaExpiredNoto = false
    var updateCalID: String?
    var currentStatusItemLoop = 0
    var connection: NSXPCConnection?
    lazy var preciseUpdateForMinuteChangeTimer = RepeatingTimer(time: minUpdateInterval)
    lazy var mainMenuOpenTimer = RepeatingTimer(time: 1.0)
    lazy var preciseUpdateForPreferencesOpenTimer = RepeatingTimer(time: minUpdateInterval)
    lazy var statusItemLoopTimer = RepeatingTimer(time: 5.0)
    lazy var statusItemTimer = RepeatingTimer(time: fastUpdateInterval)
    lazy var eventMilestoneTracker = EventTimeRemainingMonitor(delegate: self)
    lazy var defaults = HLLDefaults()
    lazy var countdownStringGenerator = CountdownStringGenerator()
    lazy var upcomingEventStringGenerator = UpcomingEventStringGenerator()
    lazy var schoolAnalyser = SchoolAnalyser()
    lazy var milestoneNotifications = MilestoneNotifications()
    lazy var calendarData = EventDataSource.shared
    lazy var statusItemTimerStringGenerator = StatusItemTimerStringGenerator(isForPreview: false)
    lazy var nextOccurStringGenerator = NextOccurenceStringGenerator()
    lazy var holidaysStringGenerator = SchoolHolidaysStringGenerator()
    lazy var eventNextOccurFinder = EventNextOccurenceFinder()
    lazy var memoryRelaunch = MemoryRelaunch()
    lazy var schoolManager = SchoolFunctionsManager()
    static var service: HLLHelperProtocol?
    var delegate: HLLMacUIController? {
        
        didSet {
            
            self.mainRunLoop()
            
        }
        
        
    }
    // let milestoneNotosch = MilestoneNotificationScheduler()
    
    
    func convertToHLLEvents(data: [Data]) -> [HLLEvent] {
        
        var returnEvents = [HLLEvent]()
        
        for dataItem in data {
            
            do { try  returnEvents.append(JSONDecoder().decode(HLLEvent.self, from: dataItem))  }
                
            catch { }
            
        }
        
        return returnEvents
        
    }
    
    func convertToHLLEvents(data: [Date : [Data]]) -> [Date : [HLLEvent]] {
        
        var returnDict = [Date : [HLLEvent]]()
        
        
        for item in data {
            
            returnDict[item.key] = convertToHLLEvents(data: item.value)
            
        }
        
        return returnDict
    }
    
    func setupXPC() {
        
        connection = NSXPCConnection(serviceName: "ryankontos.How-Long-Left-Helper")
        connection?.remoteObjectInterface = NSXPCInterface(with: HLLHelperProtocol.self)
        connection?.resume()
        
        Main.service = connection?.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
            } as? HLLHelperProtocol
        
        
    }
    
    init(aDelegate: HLLMacUIController) {
        
     //   setupXPC()
        
        DispatchQueue.main.async {
            
            self.delegate = aDelegate
            
            UIController.awokeAt = Date()
            
            self.schoolAnalyser.analyseCalendar()
            
            //  betaExpiryDate = Date(timeIntervalSince1970: 1544792400)
            
            var showOnboarding = false
            
            //  if let launched = HLLDefaults.appData.launchedVersion  {
            
            if HLLDefaults.appData.launchedVersion == nil {
                
                showOnboarding = true
                
                /*  if version.currentVersion > launched {
                 
                 showOnboarding = true
                 
                 } */
                
            } else {
                
                showOnboarding = false
                
            }
            
            
            
            if showOnboarding == true {
                
                DispatchQueue.main.async {
                    
                    let defaultsMigrator = DefaultsMigrator()
                    defaultsMigrator.migrate1XXDefaults()
                    
                    self.welcomeStoryboard = NSStoryboard(name: "Onboarding", bundle: nil)
                    
                    self.welcomeWindowController = self.welcomeStoryboard.instantiateController(withIdentifier: "Onboard1") as? NSWindowController
                    self.welcomeWindowController!.showWindow(self)
                    
                }
                
                
            }
            
            
            //  let magdaleneUpdateAlert = MagdaleneUpdateAlert()
            // magdaleneUpdateAlert.CheckToShowMagdaleneChangesPrompt()
            
            HLLDefaults.appData.launchedVersion = self.version.currentVersion
            
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
            
            self.statusItemTimer.eventHandler = {
                
                self.statusItemTimerQueue.async(flags: .barrier) {
                    
                    var countdown: HLLEvent?
                    
                    if let top = EventCache.primaryEvent {
                        
                        countdown = top
                        
                    } else {
                        
                        countdown = EventCache.currentEvents.first
                        
                    }
                    
                    
                    
                    if let currentEvent = countdown, currentEvent.isHolidays == false, let timerString = self.statusItemTimerStringGenerator.generateStringFor(event: currentEvent) {
                        self.runStatusItemUIUpdate(event: currentEvent)
                        self.delegate?.updateStatusItem(with: timerString)
                        
                    } else {
                        
                        self.delegate?.updateStatusItem(with: nil)
                        
                    }
                }
                
            }
            
            self.preciseUpdateForMinuteChangeTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
            self.preciseUpdateForPreferencesOpenTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
            
            // updateCalendarData(doGlobal: false)
            
            //   mainRunLoop()
            
            self.mainTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.updateInterval), target: self, selector: #selector(self.mainRunLoop), userInfo: nil, repeats: true)
            self.frequentLowUsageTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkEvents), userInfo: nil, repeats: true)
            self.dataUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(self.updateCalendarData), userInfo: nil, repeats: true)
            self.checkForUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(self.doUpdateCheck), userInfo: nil, repeats: true)
            
            self.mainMenuOpenTimer.eventHandler = {
                
                
                
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.doUpdateCheck()
            }
            
            RunLoop.main.add(self.mainTimer!, forMode: .common)
            RunLoop.main.add(self.frequentLowUsageTimer, forMode: .common)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.calendarDidChange),
                name: .EKEventStoreChanged,
                object: nil)
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateGlobalTrigger), name: Notification.Name("updateCalendar"), object: nil)
            
            print("Init took \(Date().timeIntervalSince(UIController.awokeAt!))s")
            
            // Ooft we've finsihed launching
            
            self.updateCalendarData(doGlobal: true)
            self.mainRunLoop()
            
        }
        
    }
    
    
    
    
    @objc func updateGlobalTrigger() {
        
        DispatchQueue.global(qos: .default).async {
            self.updateCalendarData(doGlobal: true)
        }
        
    }
    
    @objc func doUpdateCheck() {
        
        DispatchQueue.main.async {
            
            let update = self.version.updateAvaliable()
            
            self.delegate?.setUpdateAvaliableState(version: update)
            
            if let uUpdate = update, self.shownUpdateNotification == false {
                
                self.sendUpdateAvaliableNotification(version: uUpdate)
                self.shownUpdateNotification = true
                
            }
            
        }
        
    }
    
    @objc func preciseMainRunLoopTrigger() {
        self.mainRunLoop()
      //  print("Precise trigger")
    }
    
    @objc func checkEvents() {
        
        frequentLowUsageQueue.async(flags: .barrier) {
            
            
            self.eventMilestoneTracker.checkCurrentEvents()
            let second = self.calendar.component(.second, from: Date())
            if [58, 59, 0, 1].contains(second) {
                
                self.preciseUpdateForMinuteChangeTimer.resume()
                
            } else if UIController.preferencesWindowController.window!.isVisible == false {
                self.preciseUpdateForMinuteChangeTimer.suspend()
                
            }
            
            
            
            
        }
        
        if UIController.menuIsOpen == true {
            
            self.runMainMenuUIUpdate(checkOpen: false)
            
        }
        
    }
    
    @objc func mainRunLoop() {
            
            
          //  print("Main")
            
            self.calendarData.getCalendarAccess()
            
            if EventDataSource.accessToCalendar == .Denied {
                
                self.statusItemTimer.suspend()
                self.delegate?.noCalendarAccessUIState(enabled: true)
                
                if self.shownNoCalAccessNotification == false {
                    
                    self.sendNoCalAccessNotification()
                    
                }
                
                self.updateCalendarData(doGlobal: true)
                
                return
                
            } else {
                
                self.delegate?.noCalendarAccessUIState(enabled: false)
                
            }

            
            self.organiseCurrentEvents()
            
            let currentEvents = EventCache.currentEvents
            let allUpcoming = EventCache.upcomingEventsToday
            var topEvent = EventCache.primaryEvent
            
            self.checkIfPrimaryIsStillRunning()
            
            
            if topEvent == nil {
                
                topEvent = currentEvents.first
                
            }
            
            
            self.runStatusItemUIUpdate(event: topEvent)
            
            if allUpcoming.isEmpty == false {
                
                self.nextEventToStart = allUpcoming[0]
                
            } else {
                
                self.nextEventToStart = nil
                
            }
            
            if let unwrappedUpcoming = self.nextEventToStart {
                
                // If the next to start event has started, update calendar data.
                
                if unwrappedUpcoming.startDate.timeIntervalSinceNow < 1 {
                    
                    self.nextEventToStart = nil
                    self.updateCalendarData(doGlobal: true)
                    
                }
                
            }
            
            if let unwrappedLastCalendarUpdate = self.lastCalendarUpdate {
                
                if unwrappedLastCalendarUpdate.timeIntervalSinceNow < -302 || unwrappedLastCalendarUpdate.timeIntervalSinceNow > 1 {
                    
                    if self.beenTooLongWithoutUpdate == false {
                        
                        self.beenTooLongWithoutUpdate = true
                        self.updateCalendarData(doGlobal: true)
                        print("Updating calendar at \(Date()) due to too long")
                        
                    }
                    
                }
                
            }
            
                
                
                if UIController.preferencesWindowController.window!.isVisible, HLLDefaults.statusItem.mode != .Off {
                    self.preciseUpdateForPreferencesOpenTimer.resume()
                    
                    
                } else {
                    
                    self.preciseUpdateForPreferencesOpenTimer.suspend()
                    
                    
                }
                
        
            
            if let top = EventCache.primaryEvent {
                var match = false
                for event in EventCache.currentEvents {
                    
                    if event == top {
                        EventCache.fetchQueue.sync(flags: .barrier) {
                            EventCache.primaryEvent = event
                            match = true
                        }
                        
                    }
                    
                    
                }
                
                if match == false {
                    EventCache.fetchQueue.async(flags: .barrier) {
                        EventCache.primaryEvent = EventCache.currentEvents.first
                    }
                }
                
            }
            
            self.memoryRelaunch.relaunchIfNeeded()
            self.checkBetaExpiry()
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
            if HLLDefaults.calendar.enabledCalendars != EventDataSource.lastUpdatedWithCalendars {
                
                print("Update for new cal")

                self.updateCalendarData(doGlobal: true)
                
            } else if self.calendarData.latestFetchSchoolMode != SchoolAnalyser.schoolMode {
                
                self.updateCalendarData(doGlobal: true)
            }
            
            var update = false
            
            for event in EventCache.upcomingEventsToday {
                
                if event.completionStatus == EventCompletionStatus.InProgress {
                    
                    if EventCache.currentEvents.contains(event) == false {
                        
                        
                        update = true
                        
                    }
                    
                }
                
            }
            
            if update == true {
                
                self.updateCalendarData(doGlobal: true)
                
            }
        
    }
    
    @objc func calendarDidChange() {
        
        // print("Updating calendar at \(Date()) due to calendar change")
        updateCalendarData(doGlobal: true)
        print("Updating calendar at \(Date()) due to cal change")
        
        
        mainRunLoop()
        
        
    }
    
    func organiseCurrentEvents() {
        
        var currentEvents = EventCache.currentEvents
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        
        EventCache.fetchQueue.async(flags: .barrier) {
            EventCache.currentEvents = currentEvents
        }
    }
    
    func checkIfPrimaryIsStillRunning() {
        
        if let primary = EventCache.primaryEvent {
            
            var match = false
            
            for event in EventCache.currentEvents {
                
                if event == primary {
                    
                    match = true
                    
                }
                
            }
            
            if match == false {
                
                EventCache.fetchQueue.async(flags: .barrier) {
                    EventCache.primaryEvent = nil
                }
            }
            
            
        }
        
    }
    
    func runMainMenuUIUpdate(checkOpen: Bool) {
        
        if checkOpen == true, UIController.menuIsOpen {
            
            mainMenuOpenTimer.resume()
            
        }
        
        let currentEvents = calendarData.getCurrentEvents()
        let upcomingEventsToday = calendarData.getUpcomingEventsToday()
        let nextUpcomingDay = calendarData.getUpcomingEventsFromNextDayWithEvents()
        let allUpcoming = calendarData.fetchEventsFromPresetPeriod(period: .Next2Weeks)
        let upcomingWeek = calendarData.getArraysOfUpcomingEventsForNextSevenDays()
        
        
        delegate?.addCurrentEventRows(with: countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEventsToday))
        
        let upcomingEventsMenuInfo = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcomingDay)
        
        // let upcomingFuture = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcoming2)
        
        delegate?.updateNextEventItem(text: upcomingEventStringGenerator.generateNextEventString(upcomingEvents: upcomingEventsToday, currentEvents: currentEvents, isForDoneNotification: false))
            
        if checkOpen == false {
            
            return
            
        }
        
        let upcomingWeekItems = upcomingEventStringGenerator.generateUpcomingDayItems(days: upcomingWeek)
        
        let nextOccurEvents = eventNextOccurFinder.findNextOccurrences(currentEvents: currentEvents, upcomingEvents: allUpcoming)
        
        let nextOccurItems = nextOccurStringGenerator.generateNextOccurenceItems(events: nextOccurEvents)
        
        delegate?.addNextOccurRows(items: nextOccurItems)
        
        delegate?.updateUpcomingWeekMenu(data: upcomingWeekItems)
        
        delegate?.updateUpcomingEventsMenu(data: upcomingEventsMenuInfo)
        
        
        
        
        
        
    }
    
    func runStatusItemUIUpdate(event: HLLEvent?) {
        
        if let uEvent = event {
            
            if uEvent.isHolidays == true, HLLDefaults.magdalene.doHolidaysInStatusItem == false {
                
                self.statusItemTimer.suspend()
                self.delegate?.updateStatusItem(with: nil)
                return
                
            }
            
            
        }
        
        if HLLDefaults.statusItem.mode == .Timer, event?.isHolidays != true {
            
            if event != nil {
                //   statusItemTimerStrings = statusItemTimerStringGenerator.generateStringsFor(event: countdownEvent)
                
                self.statusItemTimer.resume()
                
            } else {
                
                
                self.statusItemTimer.suspend()
                delegate?.updateStatusItem(with: countdownStringGenerator.generateStatusItemString(event: nil))
                
            }
            
        } else if HLLDefaults.statusItem.mode == .Minute || event?.isHolidays == true {
            
            self.statusItemTimer.suspend()
            
            delegate?.updateStatusItem(with: countdownStringGenerator.generateStatusItemString(event: event))
            
            
        } else {
            
            delegate?.updateStatusItem(with: nil)
            
        }
        
        
    }
    
    @objc func updateCalendarData(doGlobal: Bool) {
        
        os_log("Doing event update...", log: log, type: .default)
        
        updateCalendarDataOld(doGlobal: doGlobal)
        
        
       
        
    }
    
  /*  @objc func updateOverXPC() {
        
        calUpdateQueue.async(flags: .barrier) {
            
            EventCache.fetchQueue.async(flags: .barrier) {
                
                if self.inCalendarUpdateCooldown == false {
                    
                    self.inCalendarUpdateCooldown = true
                    
                    
                    self.calendarData.updateEventStore()
                    
                    if self.calendarUpdateInProgress == false {
                        
                        
                        self.calendarUpdateInProgress = true
                        print("Cal update")
                        
                        
                        Main.service?.getCurrentEvents(withReply: {data in
                            
                            EventCache.currentEvents = self.convertToHLLEvents(data: data)
                            
                        })
                        
                        Main.service?.getUpcomingEventsToday(withReply: {data in
                            
                            EventCache.upcomingEventsToday = self.convertToHLLEvents(data: data)
                            
                        })
                        
                        Main.service?.getUpcomingEventsFromNextDayWithEvents(withReply: {data in
                            
                            EventCache.nextUpcomingEventsDay = self.convertToHLLEvents(data: data)
                            
                        })
                        
                        Main.service?.getArraysOfUpcomingEventsForNextSevenDays(withReply: { data in
                            
                            EventCache.upcomingWeekEvents = self.convertToHLLEvents(data: data)
                            
                        })
                        
                        Main.service?.fetchEventsFromPresetPeriod(period: .Next2Weeks, withReply: { data in
                            
                            EventCache.allUpcomingEvents = self.convertToHLLEvents(data: data)
                            
                            
                        })
                        
                        Main.service?.fetchEventsFromPresetPeriod(period: .AllToday, withReply: { data in
                            
                            EventCache.allEventsToday = self.convertToHLLEvents(data: data)
                            
                            
                        })
                        
                        
                        
                        self.lastCalendarUpdate = Date()
                        self.calendarUpdateInProgress = false
                        self.beenTooLongWithoutUpdate = false
                        
                        
                    }
                    
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        
                        //   print("Cooldown ending")
                        self.inCalendarUpdateCooldown = false
                        
                        if self.updateRequestedDuringCooldown == true {
                            //    print("Doing update requested during cooldown")
                            self.updateRequestedDuringCooldown = false
                            self.updateCalendarData(doGlobal: false)
                            
                        }
                        
                    }
                    
                } else {
                    
                    //  print("update requested during cooldown")
                    self.updateRequestedDuringCooldown = true
                    
                }
                
                self.mainRunLoop()
                
            }
            
            
        }
    }
    */
    @objc func updateCalendarDataOld(doGlobal: Bool) {
            
                
                let updateSource = EventDataSource()
                updateSource.updateEventStore()
                EventCache.currentEvents = updateSource.getCurrentEvents()
                EventCache.upcomingEventsToday = updateSource.getUpcomingEventsToday()
                SchoolAnalyser.shared.analyseCalendar()
            
        
            
            os_log("Event update done.", log: self.log, type: .default)
       
        
        
    }
    
    func sendNoCalAccessNotification() {
        
        let notification = NSUserNotification()
        notification.title = "How Long Left"
        notification.subtitle = "No calendar access ⚠️"
        notification.informativeText = "Click to fix..."
        notification.identifier = "Cal"
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func sendUpdateAvaliableNotification(version: String) {
        
        let notification = NSUserNotification()
        notification.title = "An update for How Long Left is avaliable"
        notification.subtitle = "(v\(version))"
        notification.informativeText = "Click to view in the Mac App Store..."
        notification.identifier = "Update"
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func hotKeyPressed() {
        
        if EventDataSource.accessToCalendar == .Denied {
            
            sendNoCalAccessNotification()
            
        }
        
        let currentEvents = EventCache.currentEvents
        let upcomingEvents = EventCache.upcomingEventsToday
        
        let currentInfo = countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEvents)
        
        var countdownItem = currentInfo[0]
        
        if let preferedCountdownEvent = EventCache.primaryEvent {
            
            for eventItem in currentInfo {
                
                if let eventItemEvent = eventItem.2 {
                    
                    if eventItemEvent == preferedCountdownEvent {
                        
                        countdownItem = eventItem
                        
                    }
                    
                }
                
                
            }
            
        }
        
        let notification = NSUserNotification()
        notification.title = countdownItem.0
        
        if let percentText = countdownItem.1 {
            notification.subtitle = percentText
        }
        
        notification.informativeText = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: upcomingEvents, currentEvents: currentEvents, isForDoneNotification: false)
        //notification.soundName = "Hero"
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func milestoneReached(milestone seconds: Int, event: HLLEvent) {
        milestoneNotifications.sendNotificationFor(milestone: seconds, event: event)
    }
    
    func percentageMilestoneReached(milestone percentage: Int, event: HLLEvent) {
        
        milestoneNotifications.sendNotificationFor(percentage: percentage, event: event)
        
    }
    
    func eventStarted(event: HLLEvent) {
        
        milestoneNotifications.sendStartingNotification(for: event)
        
    }
    
    func updateDueToEventEnd(event: HLLEvent, endingNow: Bool) {
        
        
        var idArray = [HLLEvent]()
        
        EventCache.currentEvents.forEach({ event in
            
            idArray.append(event)
            
        })
        
        if let indexOfEnding = idArray.firstIndex(of: event) {
            EventCache.fetchQueue.async(flags: .barrier) {
                EventCache.currentEvents.remove(at: indexOfEnding)
            }
        }
        
        self.updateCalendarData(doGlobal: true)
        self.checkIfPrimaryIsStillRunning()
        
        if endingNow == true {
            
            preciseUpdateForMinuteChangeTimer.resume()
            
            if let topEvent = EventCache.primaryEvent {
                
                
                if event == topEvent {
                    delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                }
                
            } else {
                delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                
            }
            
            preciseUpdateForMinuteChangeTimer.suspend()
        }
        
        eventEndUpdateInProgress = true
        //  print("Updating calendar at \(Date()) due to event end")
        
        eventEndUpdateInProgress = false
        
    }
    
    func checkBetaExpiry() {
        
        if let expiry = self.betaExpiryDate, expiry.timeIntervalSinceNow < 0 {
            
            self.mainTimer?.invalidate()
            self.statusItemTimer.suspend()
            self.preciseUpdateForMinuteChangeTimer.suspend()
            self.preciseUpdateForPreferencesOpenTimer.suspend()
            
            DispatchQueue.main.async {
                
                NSApp.activate(ignoringOtherApps: true)
                let alert: NSAlert = NSAlert()
                alert.window.title = "How Long Left \(self.version.currentVersion)"
                alert.messageText = "This beta build of How Long Left has expired."
                alert.informativeText = """
                Please use a release build or obtain a newer beta.
                """
                
                alert.alertStyle = NSAlert.Style.informational
                alert.addButton(withTitle: "Quit")
                alert.runModal()
                NSApplication.shared.terminate(self)
                
            }
            
        }
        
    }
    
}
