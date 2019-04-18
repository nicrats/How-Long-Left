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
import os.log

class Main: HLLCountdownController, SchoolModeChangedDelegate {
    
    
    func schoolModeChanged() {
        self.updateCalendarData(doGlobal: true)
    }
    
    
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
    let magdaleneWifiCheck = MagdaleneWifiCheck()
    let magdalenePrompts = MagdalenePrompts()
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
    lazy var preciseUpdateForPreferencesOpenTimer = RepeatingTimer(time: 0.5)
    lazy var statusItemLoopTimer = RepeatingTimer(time: 5.0)
    lazy var statusItemTimer = RepeatingTimer(time: fastUpdateInterval)
    lazy var eventMilestoneTracker = EventTimeRemainingMonitor(delegate: self)
    lazy var defaults = HLLDefaults()
    lazy var countdownStringGenerator = CountdownStringGenerator()
    lazy var upcomingEventStringGenerator = UpcomingEventStringGenerator()
    lazy var schoolAnalyser = SchoolAnalyser()
    lazy var milestoneNotifications = MilestoneNotifications()
    lazy var calendarData = EventDataSource()
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
    
    
  /*  func convertToHLLEvents(data: [Data]) -> [HLLEvent] {
        
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
        
        
    } */
    
    init(aDelegate: HLLMacUIController) {
        
     //   setupXPC()
        
        DispatchQueue.main.async {
            
            
            
            
        self.delegate = aDelegate
            
            UIController.awokeAt = Date()
            
            self.schoolAnalyser.setLoneDelegate(to: self)
            self.schoolAnalyser.analyseCalendar()
            
            
            if HLLDefaults.defaults.bool(forKey: "changed24HourPref") == false {
                
                let locale = NSLocale.current
                let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
                if formatter.contains("a") {
                    HLLDefaults.general.use24HourTime = false
                } else {
                    
                    HLLDefaults.general.use24HourTime = true
                    
                }
                
            }
            
            
            
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
            
          //  showOnboarding = true
            
            if showOnboarding == true {
                
                DispatchQueue.main.async {
                    
                    let defaultsMigrator = DefaultsMigrator()
                    defaultsMigrator.migrate1XXDefaults()
                    
                    self.welcomeStoryboard = NSStoryboard(name: "Onboarding", bundle: nil)
                    
                    self.welcomeWindowController = self.welcomeStoryboard.instantiateController(withIdentifier: "Onboard1") as? NSWindowController
                    
                    self.welcomeWindowController!.showWindow(self)
                    
                    
                }
                
                
            }
            
            
            
            if SchoolAnalyser.schoolMode == .Magdalene {
                
               
                
                if let launched = HLLDefaults.appData.launchedVersion {
                    
                    if Version.currentVersion > launched {
                        
                        self.magdalenePrompts.presentMagdaleneChangesPrompt()
                        
                    }
                    
                } else {
                    
                    
                    self.magdalenePrompts.presentMagdaleneChangesPrompt()
                    
                    
                }
                
                
            }
            
            
            
            HLLDefaults.appData.launchedVersion = Version.currentVersion
            
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
            
            self.statusItemTimer.eventHandler = {
                
                    
                    var countdown: HLLEvent?
                    
                    if let top = EventCache.primaryEvent {
                        
                        countdown = top
                        
                    } else {
                        
                        countdown = EventCache.currentEvents.first
                        
                    }
                    
                    
                    
                    if let currentEvent = countdown, currentEvent.holidaysTerm == nil, let timerString = self.statusItemTimerStringGenerator.generateStringFor(event: currentEvent) {
                        self.runStatusItemUIUpdate(event: currentEvent)
                        self.delegate?.updateStatusItem(with: timerString)
                        
                    } else {
                        
                        self.delegate?.updateStatusItem(with: nil)
                        
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
            print("Call4")
            self.mainRunLoop()
            
            
        }
        
        let compS = ComplicationSim()
        let _ = compS.generateComplicationItems()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            
            if self.magdaleneWifiCheck.isOnMagdaleneWifi() == true, SchoolAnalyser.schoolModeIgnoringUserPreferences == SchoolMode.None, HLLDefaults.defaults.bool(forKey: "sentralPrompt") == false {
                self.magdalenePrompts.presentSentralPrompt()
                HLLDefaults.defaults.set(true, forKey: "sentralPrompt")
                
            }
            
        })
    
        
    }
    
    
    
    
    @objc func updateGlobalTrigger() {
        
        DispatchQueue.global(qos: .default).async {
            print("Call1")
            self.updateCalendarData(doGlobal: true)
        }
        
    }
    
    @objc func doUpdateCheck() {
        
        DispatchQueue.main.async {
            
            let update = self.version.updateAvaliable()
            
            if HLLDefaults.general.showUpdates == true {
            
            self.delegate?.setUpdateAvaliableState(version: update)
            
        }
            
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
        
            
            self.eventMilestoneTracker.checkCurrentEvents()
            let second = self.calendar.component(.second, from: Date())
            if [58, 59, 0, 1].contains(second) {
                
                self.preciseUpdateForMinuteChangeTimer.resume()
                
            } else if UIController.preferencesWindowController.window!.isVisible == false {
                self.preciseUpdateForMinuteChangeTimer.suspend()
                
            }
            
            
            
            
        
        
        if UIController.menuIsOpen == true {
            
            self.runMainMenuUIUpdate(checkOpen: false)
            
        }
        
    }
    
    let mainRLQ = DispatchQueue(label: "MRLQ")
    
    @objc func mainRunLoop() {
        
        mainRLQ.async(flags: .barrier) {
            
          //  print("Main")
            
            self.calendarData.getCalendarAccess()
            
            if EventDataSource.accessToCalendar == .Denied {
                
                self.statusItemTimer.suspend()
                self.delegate?.noCalendarAccessUIState(enabled: true)
                
                if self.shownNoCalAccessNotification == false {
                    
                    self.sendNoCalAccessNotification()
                    
                }
                
                self.updateCalendarData(doGlobal: true)
                print("Call2")
                
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
                    print("Call5")
                    
                }
                
            }
            
            if let unwrappedLastCalendarUpdate = self.lastCalendarUpdate {
                
                if unwrappedLastCalendarUpdate.timeIntervalSinceNow < -302 || unwrappedLastCalendarUpdate.timeIntervalSinceNow > 1 {
                    
                    if self.beenTooLongWithoutUpdate == false {
                        
                        self.beenTooLongWithoutUpdate = true
                        self.updateCalendarData(doGlobal: true)
                        print("Call6")
                        print("Updating calendar at \(Date()) due to too long")
                        
                    }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                
                
                if UIController.preferencesWindowController.window!.isVisible, HLLDefaults.statusItem.mode != .Off {
                    self.preciseUpdateForPreferencesOpenTimer.resume()
                    
                    
                } else {
                    
                    self.preciseUpdateForPreferencesOpenTimer.suspend()
                    
                    
                }
                
                
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
                print("Call7")
                
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
                print("Call9")
            }
            
            
            if let nextHolidays = self.schoolHoliday.getNextHolidays(), nextHolidays.completionStatus == .InProgress {
                
            if HLLDefaults.defaults.string(forKey: "shownHolidaysPrompt") != nextHolidays.identifier {
                
                HLLDefaults.defaults.set(nextHolidays.identifier, forKey: "shownHolidaysPrompt")
                
                self.magdalenePrompts.presentSchoolHolidaysPrompt()
                
                
                }
            }
            
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
        
        let countdownData = countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEventsToday, allUpcoming: allUpcoming)
       
        
        let upcomingEventsMenuInfo = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcomingDay)
        
        // let upcomingFuture = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcoming2)
        
        delegate?.updateNextEventItem(text: upcomingEventStringGenerator.generateNextEventString(upcomingEvents: nextUpcomingDay, currentEvents: currentEvents, isForDoneNotification: false))
        
        delegate?.updateExistingCurrentEventRows(with: countdownData)
        
        let holidays = MagdaleneSchoolHolidays()
        var tData: TermData?
        
        if let next = holidays.getNextHolidays() {
            
            tData = TermData(nextHolidays: next)
            
        }
        
        
        
        delegate?.updateTermDataMenu(termData: tData)
        
        if checkOpen == false {
            
            return
            
        }
        
        // Stuff below here is only done on menu open.
        
         delegate?.addCurrentEventRows(with: countdownData, updateNextOccurs: false)
        
        
        
        let upcomingWeekItems = upcomingEventStringGenerator.generateUpcomingDayItems(days: upcomingWeek)
        
     //   let nextOccurEvents = eventNextOccurFinder.findNextOccurrences(currentEvents: currentEvents, upcomingEvents: allUpcoming)
        
       // let nextOccurItems = nextOccurStringGenerator.generateNextOccurenceItems(events: nextOccurEvents)
        
      //  delegate?.addNextOccurRows(items: nextOccurItems)
        
        delegate?.updateUpcomingWeekMenu(data: upcomingWeekItems)
        
        delegate?.updateUpcomingEventsMenu(data: upcomingEventsMenuInfo)
        
        
        
        
        
        
        
    }
    
    let SIQueue = DispatchQueue(label: "SIQ")
    
    func runStatusItemUIUpdate(event: HLLEvent?) {
        
        
        SIQueue.async(flags: .barrier) {
        
        if let uEvent = event {
            
            if uEvent.holidaysTerm != nil, HLLDefaults.magdalene.doHolidaysInStatusItem == false {
                
                self.statusItemTimer.suspend()
                self.delegate?.updateStatusItem(with: nil)
                return
                
            }
            
            
        }
        
        if HLLDefaults.statusItem.mode == .Timer, event?.holidaysTerm == nil {
            
            if event != nil {
                //   statusItemTimerStrings = statusItemTimerStringGenerator.generateStringsFor(event: countdownEvent)
                
                self.statusItemTimer.resume()
                
            } else {
                
                 self.statusItemTimer.suspend()
            
                self.delegate?.updateStatusItem(with: self.countdownStringGenerator.generateStatusItemString(event: nil))
                
            
            }
            
        } else if HLLDefaults.statusItem.mode == .Minute || event?.holidaysTerm != nil {
            
            self.statusItemTimer.suspend()
            
            self.delegate?.updateStatusItem(with: self.countdownStringGenerator.generateStatusItemString(event: event))
            
            
        } else {
            
            self.delegate?.updateStatusItem(with: nil)
            
        }
            
        }
        
        
    }
    
    @objc func updateCalendarData(doGlobal: Bool) {
        
        os_log("Doing event update...", log: log, type: .default)
        
        updateCalendarDataOld(doGlobal: doGlobal)
        
        
       
        
    }
    
    @objc func updateCalendarDataOld(doGlobal: Bool) {
            
        
        calUpdateQueue.async(flags: .barrier) {
        
            SchoolAnalyser.shared.analyseCalendar()
            
                let updateSource = EventDataSource()
                updateSource.updateEventStore()
                EventCache.currentEvents = updateSource.getCurrentEvents()
                EventCache.upcomingEventsToday = updateSource.getUpcomingEventsToday()
                SchoolAnalyser.shared.analyseCalendar()
                EventCache.allToday = updateSource.fetchEventsFromPresetPeriod(period: .AllToday)
            
        }
        
            
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
        
        
        let currentInfo = countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEvents, allUpcoming: nil)
        
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
        
        if HLLDefaults.notifications.startNotifications == true {
        milestoneNotifications.sendStartingNotification(for: event)
            
        }
        
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
        print("Call10")
        self.checkIfPrimaryIsStillRunning()
        
        if endingNow == true {
            
            preciseUpdateForMinuteChangeTimer.resume()
            
            if let topEvent = EventCache.primaryEvent {
                
                
                if event == topEvent {
                    
                    if HLLDefaults.statusItem.doneAlerts == true {
                    
                    delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                        
                    }
                }
                
            } else {
                if HLLDefaults.statusItem.doneAlerts == true {
                    
                    delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                    
                }
                
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
                alert.window.title = "How Long Left \(Version.currentVersion)"
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
