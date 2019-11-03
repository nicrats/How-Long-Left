//
//  HLLMain.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 30/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//
import Foundation
import HotKey
import AppKit
import StoreKit

class HLLMain: NSObject, HLLCountdownController, NSWindowDelegate, EventPoolUpdateObserver {
    func eventPoolUpdated() {
        
        let events = HLLEventSource.shared.eventPool
        if let id = HLLDefaults.defaults.string(forKey: "SelectedEvent"), id.isEmpty == false {
            
            for event in events {
                
                if event.identifier == id {
                    
                    SelectedEventManager.selectedEvent = event
                    print("SelectedSet 2")
                    break
                    
                }
                
            }
            
            
        }
        
        if doneLaunchEventPoolChecks == false {
        
            if self.magdaleneWifiCheck.isOnMagdaleneWifi() == true, SchoolAnalyser.privSchoolMode == SchoolMode.None, HLLDefaults.defaults.bool(forKey: "doneWifiSentralPrompt") != true {
                
                self.magdalenePrompts.presentSentralPrompt(reinstall: false)
                HLLDefaults.defaults.set(true, forKey: "doneWifiSentralPrompt")
                
            } else if SchoolAnalyser.privSchoolMode == .Magdalene {
                
                HLLDefaults.defaults.set(false, forKey: "doneWifiSentralPrompt")
                
            }
        
            
        self.magdalenePrompts.presentMagdaleneChangesPrompt()
        HLLDefaults.appData.launchedVersion = Version.currentVersion
         
            doneLaunchEventPoolChecks = true
            
        }
        
        updateCalendarData()
    }
    
    static var proUser = true
    
    static var shared: HLLMain?
    var doneLaunchEventPoolChecks = false
    var updateInterval = 5
    var fastUpdateInterval = 0.30
    var minUpdateInterval = 0.75
    var calUpdateQueue = DispatchQueue(label: "calendarUpdate")
    var version = Version()
    var magdaleneWifiCheck = MagdaleneWifiCheck()
    var magdalenePrompts = MagdalenePrompts()
    var nextEventToStart: HLLEvent?
    var lastTotalCalendars = 0
    var CDUIWindowController : NSWindowController?
    var CDUIStoryboard = NSStoryboard()
    var MainUIWindowController : NSWindowController?
    var MainUIStoryboard = NSStoryboard()
    var welcomeWindowController : NSWindowController?
    var welcomeStoryboard = NSStoryboard()
    var mainTimer: Timer?
    var windowCheckTimer: Timer?
    var dataUpdateTimer: Timer!
    var frequentLowUsageTimer: Timer!
    var irregularTimer: Timer!
    var lastCalendarUpdate: Date?
    let calendar = NSCalendar.current
    let schoolHolidays = SchoolHolidayEventFetcher()
    var eventEndUpdateInProgress = false
    var calendarUpdateInProgress = false
    var beenTooLongWithoutUpdate = false
    var updatingStatusItemTimer = false
    var fastTimerMode = false
    var statusItemTimerRunning = false
    var shownUpdateNotification = false
    var shownNoCalAccessNotification = false
    var shownBetaExpiredNoto = false
    var updateCalID: String?
    var confirmedPassedOnboarding = false
    lazy var preciseUpdateForMinuteChangeTimer = RepeatingTimer(time: minUpdateInterval)
    lazy var statusItemTimer = RepeatingTimer(time: fastUpdateInterval)
    lazy var eventMilestoneTracker = EventTimeRemainingMonitor(delegate: self)
    var defaults = HLLDefaults()
    var countdownStringGenerator = CountdownStringGenerator()
    var upcomingEventStringGenerator = UpcomingEventStringGenerator()
    var schoolAnalyser = SchoolAnalyser()
    var milestoneNotifications = MilestoneNotificationGenerator()
    
    var memoryRelaunch = MemoryRelaunch()
    let topShelfGen = MenuTopShelfGenerator()
    let upcomingWeekGen = UpcomingWeekMenuGenerator()
    var nextUpcomingDayAll = [HLLEvent]()
    
    var primaryEvent: HLLEvent? {
        
        get {
            
            var event = SelectedEventManager.selectedEvent
            
            if event == nil, HLLDefaults.statusItem.showCurrent {
                event = getStatusItemCurrentEvents().first
            }
            
            if event == nil, HLLDefaults.statusItem.showUpcoming, HLLMain.proUser {
                event = getNextUpcomingDayAllEvents().first
            }
            
            return event
            
        }
    }
    
    func getNextUpcomingDayAllEvents() -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        
        if HLLDefaults.general.showAllDayInStatusItem == true {
            
            returnArray = nextUpcomingDayAll
            
        } else {
            
            for event in nextUpcomingDayAll {
                
                if event.isAllDay == false {
                    
                    returnArray.append(event)
                    
                }
                
            }
            
        }
        
        return returnArray
    }
    
    func getStatusItemCurrentEvents() -> [HLLEvent] {
        
        var returnArray = [HLLEvent]()
        
        
        if HLLDefaults.general.showAllDayInStatusItem == true {
            
            returnArray = currentEvents
            
        } else {
            
            for event in currentEvents {
                
                if event.isAllDay == false {
                    
                    returnArray.append(event)
                    
                }
            }
        }
        
        return returnArray
        
    }
    
    var menuCurrentEvents = [HLLEvent]()
    
    var delegate: MenuController? {
        
        didSet {
            
            self.mainRunLoop()
            
        }
        
        
    }
    
    init(aDelegate: MenuController) {
        
        
        super.init()
        
        self.welcomeStoryboard = NSStoryboard(name: "Onboarding", bundle: nil)
        self.welcomeWindowController = self.welcomeStoryboard.instantiateController(withIdentifier: "Onboard1") as? NSWindowController
        self.welcomeWindowController!.showWindow(self)
        
        HLLMain.shared = self
        self.getLinks()
        HLLEventSource.shared.addEventPoolObserver(self)
        self.updateCalendarData()
        
        
        
        self.delegate = aDelegate
            
            MenuController.awokeAt = Date()
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
            
            var showOnboarding = false
            if HLLDefaults.appData.launchedVersion == nil {
                
                showOnboarding = true
                
            } else {
                
                showOnboarding = false
                
            }
            
            if showOnboarding == true {
                
                self.confirmedPassedOnboarding = false
                
                    
                
                  
                    
                    self.welcomeStoryboard = NSStoryboard(name: "Onboarding", bundle: nil)
                    
                    self.welcomeWindowController = self.welcomeStoryboard.instantiateController(withIdentifier: "Onboard1") as? NSWindowController
                    
                    self.welcomeWindowController!.window!.delegate = self
                    self.welcomeWindowController!.showWindow(self)
                
            } else {
                
                self.confirmedPassedOnboarding = true
                
            }
            
        
        
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
            self.statusItemTimer.eventHandler = {
                
                self.getTextForStatusItem()
            }
            
            DispatchQueue.main.async {
           
                
                
            self.statusItemTimer.resume()
            self.preciseUpdateForMinuteChangeTimer.eventHandler = { self.preciseMainRunLoopTrigger() }
                self.setupTimers()
            

            NotificationCenter.default.addObserver(self, selector: #selector(self.updateGlobalTrigger), name: Notification.Name("updateCalendar"), object: nil)
                
                let workspaceCenter = NSWorkspace.shared.notificationCenter
                workspaceCenter.addObserver(self, selector: #selector(self.computerWillSleep), name: NSWorkspace.willSleepNotification, object: nil)
                
                workspaceCenter.addObserver(self, selector: #selector(self.computerWillWake), name: NSWorkspace.didWakeNotification, object: nil)
                
               
                
            print("Init took \(Date().timeIntervalSince(MenuController.awokeAt!))s")
         
            }
            print("Call4")
            self.mainRunLoop()
            self.irregularLowPriorityUpdate()
        
        
    
        
    }
    
    
    @objc func computerWillSleep() {
        
        mainTimer?.invalidate()
        frequentLowUsageTimer.invalidate()
        windowCheckTimer?.invalidate()
        irregularTimer.invalidate()
        print("Will sleep")
        
        
    }
    
    @objc func computerWillWake() {
        
        setupTimers()
        print("Did wake")
        
    }
    
    func setupTimers() {
        
        self.mainTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.updateInterval), target: self, selector: #selector(self.mainRunLoop), userInfo: nil, repeats: true)
        self.frequentLowUsageTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(self.checkEvents), userInfo: nil, repeats: true)
        self.windowCheckTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(self.checkWindowsForDockIcon), userInfo: nil, repeats: true)
        self.irregularTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(self.irregularLowPriorityUpdate), userInfo: nil, repeats: true)
        RunLoop.main.add(self.mainTimer!, forMode: .common)
        RunLoop.main.add(self.irregularTimer, forMode: .common)
        RunLoop.main.add(self.frequentLowUsageTimer, forMode: .common)
        RunLoop.main.add(self.windowCheckTimer!, forMode: .common)
        
    }
    
    var updatingStatusItem = false
    
    func getTextForStatusItem() {
        
            if self.updatingStatusItem == true {
                return
            }
        
            self.updatingStatusItem = true
            
            let text = self.countdownStringGenerator.generateStatusItemString(event: self.primaryEvent, mode: HLLDefaults.statusItem.mode)
        
            let selected = self.primaryEvent == SelectedEventManager.selectedEvent
        
            self.delegate?.updateStatusItem(with: text, selected: selected)
            
            self.updatingStatusItem = false

    }
    
    func checkForRename() {
            
            print("Checking rename")
            let renameChecker = RNDataStore()
            if renameChecker.renameAvaliable() {
                
            self.presentRNUI()
                
            } else {
                
                print("Rename unavaliable")
                
            }
        
    }
    
    func presentRNUI() {
        RNUIManager.shared.present()
       
    }
    
    @objc func updateGlobalTrigger() {
        
        
            print("Call1")
            HLLEventSource.shared.updateEventPool()
        print("PoolC5")
            self.updateCalendarData()
        
        
    }

    @objc func preciseMainRunLoopTrigger() {
        self.mainRunLoop()
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
        
        if windows.count > 1 {
            NSApp.setActivationPolicy(.regular)
        } else {
            
           NSApp.setActivationPolicy(.accessory)
            
        }
        
        
    }
    
    var checkingEvents = false
    
    @objc func checkEvents() {
        
        self.eventMilestoneTracker.checkEventProgress(allToday: self.allToday)
            
        let second = self.calendar.component(.second, from: Date())
            if [58, 59, 0, 1].contains(second) {
                
                self.preciseUpdateForMinuteChangeTimer.resume()
                
            } else if MenuController.preferencesWindowController?.window!.isVisible == false {
                self.preciseUpdateForMinuteChangeTimer.suspend()
                
            }

        
        if let selected = SelectedEventManager.selectedEvent {
            
            if selected.isTerm == true {
                
                if HLLDefaults.magdalene.doTerm == false {
                    
                    SelectedEventManager.selectedEvent = nil
                    
                }
                
            }
            
            if selected.isPrelims == true {
                
                if HLLDefaults.magdalene.showPrelims == false {
                    
                    SelectedEventManager.selectedEvent = nil
                    
                }
                
            }
            
            
        }
        
        if let selected = SelectedEventManager.selectedEvent {
            
            if selected.holidaysTerm != nil {
                
                if HLLDefaults.magdalene.doHolidays == false {
                    
                    SelectedEventManager.selectedEvent = nil
                    
                }
                
            }
            
            
        }
        
            
        
    }
    
    let mainRLQ = DispatchQueue(label: "MRLQ")
    
    var doingMainRunLoop = false
    
    
    @objc func mainRunLoop() {
        
        
            if self.doingMainRunLoop == true {
            return
        }
        
        
        
        
            self.doingMainRunLoop = true
        
            
            
            if HLLEventSource.accessToCalendar == .Denied {
                
                self.delegate?.noCalendarAccessUIState(enabled: true)
                
                self.statusItemTimer.suspend()
                
                if self.shownNoCalAccessNotification == false {
                    self.sendNoCalAccessNotification()
                }
                
                 print("cup6")
                self.doingMainRunLoop = false
                return
                
            } else {
                
                self.delegate?.noCalendarAccessUIState(enabled: false)
                self.statusItemTimer.resume()
                
            }
            
            self.organiseCurrentEvents()
            
            for event in self.menuCurrentEvents {
                
                if event.endDate.timeIntervalSinceNow < 1 {
                    
                    self.updateCalendarData()
                     print("cup5")
                    
                }
                
                
            }
            
            if let primary = self.primaryEvent {
                
                if primary.endDate.timeIntervalSinceNow < 1 {
                    
                    self.updateCalendarData()
                     print("cup4")
                    
                }
                
            }

            
            if let unwrappedUpcoming = self.nextEventToStart {
                
                // If the next to start event has started, update calendar data.
                
                if unwrappedUpcoming.startDate.timeIntervalSinceNow < 1 {
                    
                    self.nextEventToStart = nil
                    self.updateCalendarData()
                    print("Call5")
                    
                }
                
            }
            
            if let unwrappedLastCalendarUpdate = self.lastCalendarUpdate {
                
                if unwrappedLastCalendarUpdate.timeIntervalSinceNow < -302 || unwrappedLastCalendarUpdate.timeIntervalSinceNow > 1 {
                    
                    if self.beenTooLongWithoutUpdate == false {
                        
                        self.beenTooLongWithoutUpdate = true
                        self.updateCalendarData()
                        print("Call6")
                        print("Updating calendar at \(Date()) due to too long")
                        
                    }
                    
                }
                
            }
            
        if let unwrappedLastCalendarUpdate = self.lastCalendarUpdate {
            
            if unwrappedLastCalendarUpdate.timeIntervalSinceNow < -900 || unwrappedLastCalendarUpdate.timeIntervalSinceNow > 1 {
                

                    
                    HLLEventSource.shared.updateEventPool()
                    self.updateCalendarData()
                    print("Call6")
                    print("Updating pool at \(Date()) due to too long")
                    
                
                
            }
            
        }
    
            
            self.memoryRelaunch.relaunchIfNeeded()
            self.delegate?.setHotkey(to: HLLDefaults.notifications.hotkey)
            
           
            
            var update = false
            
            for event in self.upcomingEventsToday {
                
                if event.completionStatus == EventCompletionStatus.Current {
                    
                    if self.currentEvents.contains(event) == false {
                        
                        
                        update = true
                        
                    }
                    
                }
                
            }
            
            if update == true {
                
                self.updateCalendarData()
                print("Call9")
            }
            
            
            if let nextHolidays = self.schoolHolidays.getNextHolidays(), nextHolidays.completionStatus == .Current, nextHolidays.startDate.timeIntervalSinceNow > -172800 {
                
            if HLLDefaults.defaults.string(forKey: "shownHolidaysPrompt") != nextHolidays.identifier {
                
                HLLDefaults.defaults.set(nextHolidays.identifier, forKey: "shownHolidaysPrompt")
                
                self.magdalenePrompts.presentSchoolHolidaysPrompt()
                
                
                }
            }
                
            if self.confirmedPassedOnboarding == true {
            
            let totalCals = HLLEventSource.shared.getCalendarIDS().count
            
            if totalCals != self.lastTotalCalendars {
                
                if HLLDefaults.rename.promptToRename {
                
                    print("CFRN")
                    self.checkForRename()
                    
                }
                
            }
            
            self.lastTotalCalendars = totalCals
            
        }
        
       
            self.doingMainRunLoop = false
        
        
           
            
        
            
    }
    
    var eventChangeTimer: Timer?
    
    @objc func calendarDidChange() {
        
        print("CalChange: Calendar change called")
        
        if eventChangeTimer == nil {
            
            eventChangeTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.doCalendarUpdateForCalendarChange), userInfo: nil, repeats: false)
            print("CalChange: Set timer")
            
        }

    }
    
    @objc func doCalendarUpdateForCalendarChange() {
            
        if !HLLEventSource.isRenaming {
        
            DispatchQueue.global(qos: .default).async {
            
            HLLEventSource.shared.updateEventPool()
            self.updateCalendarData()
            HLLEventSource.shared.eventStore.reset()
                
            }
            
            print("CalChange: Updating calendar at \(Date().formattedTime()) due to cal change")
            
        }
        
        eventChangeTimer = nil
            
        
        
    }
    
    let termFetch = TermEventFetcher()
    
    var hasRunIreg = false
    
    @objc func irregularLowPriorityUpdate() {
        
        if hasRunIreg {
        HLLEventSource.shared.updateEventPool()
        self.updateCalendarData()
        }
        
        if SchoolAnalyser.schoolMode == .Magdalene {
            
        if self.schoolAnalyser.getMagdaleneTitles(from: self.allUpcomingEvents, includeRenamed: true).isEmpty {
        
            if let currentHolidays = self.schoolHolidays.getCurrentHolidays() {
            
            if currentHolidays.endDate.timeIntervalSinceNow < TimeInterval.day*2 {
                
                if HLLDefaults.defaults.string(forKey: "ShownHolidaysEndSentralPrompt") != currentHolidays.identifier {
                
                    self.magdalenePrompts.presentSentralPrompt(reinstall: true)
                HLLDefaults.defaults.set(currentHolidays.identifier, forKey: "ShownHolidaysEndSentralPrompt")
                    
                }
                
                
            }
            
            
        } else {
            
            
                if let currentTerm = self.termFetch.getCurrentTermEvent(), currentTerm.endDate.timeIntervalSinceNow > TimeInterval.day*2 {
                
                if HLLDefaults.defaults.string(forKey: "ShownTermSentralPrompt") != currentTerm.identifier  {
                    
                    
                    self.magdalenePrompts.presentSentralPrompt(reinstall: true)
                    HLLDefaults.defaults.set(currentTerm.identifier, forKey: "ShownTermSentralPrompt")
                    
                }
                
                
            }
            
            }
            
            }
            
            self.getLinks()
            
        }
            hasRunIreg = true
        
        
    }
    
    func organiseCurrentEvents() {
        
        var currentEvents = self.currentEvents
        currentEvents.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        
    }
    
    var upcomingWeek = [DateOfEvents]()
    
    var topShelfItems = [NSMenuItem]()
    var upcomingWeekItem = NSMenuItem()
    
    func runMainMenuUIUpdate(checkOpen: Bool) {
        
        DispatchQueue.global(qos: .userInteractive).sync {
        
            self.topShelfItems = self.topShelfGen.generateTopShelfMenuItems(currentEvents: self.menuCurrentEvents, upcomingEventsToday: self.nextUpcomingDayAll)
            self.delegate?.setTopShelfItems(self.topShelfItems)
           
            DispatchQueue.global(qos: .userInteractive).async {
                self.upcomingWeekItem = self.upcomingWeekGen.generateUpcomingWeekMenuItem(for: self.upcomingWeek)
                self.delegate?.updateUpcomingWeekMenu(with: self.upcomingWeekItem)
            }
            
        }
        
    }
    
    let SIQueue = DispatchQueue(label: "SIQ")
    
    var updatingCalendar = false
    
    let calendarUpdateQueue = DispatchQueue(label: "calendarUpdateQueue")
    
    let serialQueue = DispatchQueue(label: "serialCalQueue")
    
    var allUpcomingEvents = [HLLEvent]()
    
    @objc func updateCalendarData() {
        
        print("Cal update")
   
            self.currentEvents = HLLEventSource.shared.getCurrentEvents()
            self.menuCurrentEvents = HLLEventSource.shared.getCurrentEvents(includeHidden: true)
            self.upcomingEventsToday = HLLEventSource.shared.getUpcomingEventsToday()
            self.allToday = HLLEventSource.shared.fetchEventsFromPresetPeriod(period: .AllToday)
            self.allUpcomingEvents = HLLEventSource.shared.fetchEventsFromPresetPeriod(period: .Next2Weeks)
            FollowingOccurenceStore.shared.updateNextOccurenceDictionary(events: self.allUpcomingEvents)
            self.nextUpcomingDayAll = HLLEventSource.shared.getUpcomingEventsFromNextDayWithEvents(includeStarted: false)
            self.upcomingWeek = HLLEventSource.shared.getArraysOfUpcomingEventsForNextSevenDays(returnEmptyItems: true)
            if var selectedEvent = SelectedEventManager.selectedEvent {
                
                SelectedEventManager.selectedEvent = selectedEvent.refresh()
                  
                if selectedEvent.completionStatus == EventCompletionStatus.Done {
                    
                    SelectedEventManager.selectedEvent = nil
                    print("SelectedSet 1")
                    
                }
                    
            }
            
        
        
    }
    
    var currentEvents = [HLLEvent]()
    var upcomingEventsToday = [HLLEvent]()
    var allToday = [HLLEvent]()
    var schoolEvents = [HLLEvent]()
    
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
        
        if HLLEventSource.accessToCalendar == .Denied {
            
            sendNoCalAccessNotification()
            
        }
        
        var notoTitle = "No events are on right now"
        var percentText: String?
        
        let notification = NSUserNotification()
        notification.identifier = ""
        
        notification.informativeText = upcomingEventStringGenerator.generateNextEventString(upcomingEvents: self.nextUpcomingDayAll)
        
        if let event = primaryEvent {
            
            if event.completionStatus == .Upcoming {
                
                notification.informativeText = nil
                
            }
            
            let currentInfo = countdownStringGenerator.generateCountdownTextFor(event: event, showEndTime: false)
            
            notoTitle = currentInfo.mainText
            
            if let percent = currentInfo.percentageText {
                
                percentText = "(\(percent) Done)"
                
            }
            
            
            
        }
        
        notification.title = notoTitle
        notification.subtitle = percentText
        
        
        
        
        
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
    func doNotDisturbEnabled() -> Bool {
        
        var returnValue = false
        
        if let ncUIDefaults = UserDefaults(suiteName: "com.apple.notificationcenterui") {
            
            if ncUIDefaults.bool(forKey: "doNotDisturb") {
                
                returnValue = true
                
            }
            
        }
        
        return returnValue
        
    }
    
    func milestoneReached(milestone seconds: Int, event: HLLEvent) {
        print("Milestone")
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
            
                self.currentEvents.remove(at: indexOfEnding)
                self.menuCurrentEvents.remove(at: indexOfEnding)
                
            
        }
        
      
        
        if endingNow == true {
            
            preciseUpdateForMinuteChangeTimer.resume()
                
                if HLLDefaults.statusItem.doneAlerts == true {
                    
                    self.delegate?.doStatusItemAlert(with: ["\(event.shortTitle) is done"])
                    
            }
            
            preciseUpdateForMinuteChangeTimer.suspend()
        }
        
        eventEndUpdateInProgress = true
        
        print("cup1")
        //  print("Updating calendar at \(Date()) due to event end")
        
        eventEndUpdateInProgress = false
        
        
        
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        if sender == self.welcomeWindowController?.window {
            
            self.welcomeWindowController = nil
            confirmedPassedOnboarding = true
            
        }
        
        return true
    }
    
    
    static var boizLinks = [URL]()
    
    func getLinks() {
        
        DispatchQueue.global(qos: .default).async {
            
        
        if SchoolAnalyser.schoolMode == .Magdalene {
        
        var returnArray = [URL]()
        
        if let url = URL(string: "https://textuploader.com/11uay/raw") {
            
            do {
                
                let contents = try String(contentsOf: url)
                
                let lines = contents.split { $0.isNewline }
                
                for line in lines {
                    
                    if let link = URL(string: String(line)) {
                        
                        print("Link! \(line)")
                        returnArray.append(link)
                        
                    }
                    
                }
                
                HLLMain.boizLinks = returnArray
                
                
            } catch {
               HLLMain.boizLinks = returnArray
            }
        } else {
            HLLMain.boizLinks = returnArray
        }
        
    }
        }
        
    }
    
}
