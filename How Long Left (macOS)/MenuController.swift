//
//  UIController.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit
import HotKey
import Preferences

class MenuController: NSObject, MenuControllerProtocol, NSMenuDelegate, NSWindowDelegate {
    
    static var shared: MenuController?

    var menuCloseTimer: Timer?
    static var awokeAt: Date?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let SIAttribute = [ NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 14.0)!]
    let icon = NSImage(named: "statusIcon")!
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var upcomingFutureRow: NSMenuItem!
    @IBOutlet weak var upcomingEventsRow: NSMenuItem!
    @IBOutlet weak var upcomingEventsMenu: NSMenu!
    @IBOutlet weak var holidaysCountToRow: NSMenuItem!
    @IBOutlet weak var upcomingFutureMenu: NSMenu!
    @IBOutlet weak var nextOccurRow: NSMenuItem!
    @IBOutlet weak var noCalAccessInfo: NSMenuItem!
    @IBOutlet weak var noCalAccessButton: NSMenuItem!
    @IBOutlet weak var edvalButton: NSMenuItem!
    @IBOutlet weak var appInfoRow: NSMenuItem!
    @IBOutlet weak var updateAvaliableItem: NSMenuItem!
    @IBOutlet weak var termRow: NSMenuItem!
    @IBOutlet weak var termMenu: NSMenu!
    static var menuIsOpen = false
    var inNoAccessMode = false
    lazy var main = Main(aDelegate: self as MenuControllerProtocol)
    let version = Version()
    var arrayOfCurrentEventMenuItems = [NSMenuItem]()
    var arrayOfUpcomingEventMenuItems = [NSMenuItem]()
    var doingStatusItemAlert = false
    var currentStatusItemText: String?
    var statusItemIsEmpty = false
    var clickedID: HLLEvent?
    let nextOccurGen = NextOccurenceStringGenerator()
    let nextOccurFind = EventNextOccurenceFinder()
    let schoolAnalyser = SchoolAnalyser()
    var countdownMenuItemEvents: [NSMenuItem: HLLEvent] = [:]
    var currentEventWindowButtons: [NSMenuItem: HLLEvent] = [:]
    var nextOccurMenuItems = [NSMenuItem]()

    private var hotKey: HotKey? {
        didSet {
            
            guard let hotKey = hotKey else {
                return
            }
            
            hotKey.keyDownHandler = {
                
                DispatchQueue.global(qos: .default).async {
                
                print("Hot Key down")
                    
                
                if self.inNoAccessMode == true {
                    
                    
                    
                } else {
                    
                   self.main.hotKeyPressed()
                    
                }
                
            }
                
            }
        }
    }
    
    
    var hotKeyState = HLLHotKeyOption.Off
    
    var compileDate: Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    override func awakeFromNib() {
 
        
            self.main.mainRunLoop()
        MenuController.shared = self
        
        schoolAnalyser.analyseCalendar()
        print("SA5")
        
            let currentVersion = Version.currentVersion
        
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
            self.appInfoRow.title = "How Long Left \(currentVersion) (\(build!))"
        
        
            self.statusItem.menu = self.mainMenu
            self.icon.isTemplate = true
            self.statusItem.image = self.icon
            self.mainMenu.removeItem(at: 0)
            self.mainMenu.delegate = self as NSMenuDelegate
        
    }
    
    func menuDidClose(_ menu: NSMenu) {
        
        if menu == mainMenu {
        MenuController.menuIsOpen = false
            self.main.mainRunLoop()
            
            
        }
        
    }
    

    
    
    func menuWillOpen(_ menu: NSMenu) {
        
        
        if menu == mainMenu {
           MenuController.menuIsOpen = true
            main.runMainMenuUIUpdate(checkOpen: true)
            
            if SchoolAnalyser.schoolMode == .Magdalene, HLLDefaults.magdalene.showEdvalButton == true {
                
                edvalButton.isHidden = false
                
                
            } else {
                
                edvalButton.isHidden = true
                
            }
            
            if NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) {
                
                
                appInfoRow.isHidden = false
                
                
                
                
            } else {
                
                appInfoRow.isHidden = true
            }
            
            if EventDataSource.accessToCalendar == .Denied {
            
                upcomingEventsRow.isHidden = true
                nextOccurRow.isHidden = true
                upcomingFutureRow.isHidden = true
                noCalAccessInfo.isHidden = false
                noCalAccessButton.isHidden = false
                
            } else {
                
                noCalAccessInfo.isHidden = true
                noCalAccessButton.isHidden = true
                
            }
            
            if HLLDefaults.general.showUpdates == false {
                
                updateAvaliableItem.isHidden = true
                
            }

        }
    
    }
    
    var settingHotKey = false
    
    func setHotkey(to: HLLHotKeyOption) {
        
       
        
        if to != hotKeyState, settingHotKey == false {
        settingHotKey = true
            
        switch to {
            
        case .Off:
            hotKey = nil
            hotKeyState = .Off
            print("Hot Key is now Off.")
        case .OptionW:
            hotKey = HotKey(key: .w, modifiers: [.option])
            print("Hot Key is now OptionW.")
            hotKeyState = .OptionW
        case .CommandT:
            hotKey = HotKey(key: .t, modifiers: [.command])
            print("Hot Key is now CommandT.")
            hotKeyState = .CommandT
        }
            
            settingHotKey = false
            
        }
        
    }
    
    
    @IBAction func edvalButtonClicked(_ sender: NSMenuItem) {
        
        openEdval()
    }
    
    func openEdval() {
        
        if let url = URL(string: "https://spring.edval.education/timetable") {
            NSWorkspace.shared.open(url)
            print("Edval was successfully opened")
        }
        
        
    }
    
    func updateStatusItem(with text: String?) {
        
        
        
        if self.doingStatusItemAlert == false {
        
        if let unwrappedText = text, HLLDefaults.statusItem.mode != .Off {
            
                DispatchQueue.main.async {
                    
                    [unowned self] in
                    
                self.statusItem.image = nil
                self.statusItem.attributedTitle = NSAttributedString(string: unwrappedText, attributes: self.SIAttribute)
                self.currentStatusItemText = unwrappedText
                self.statusItemIsEmpty = false
                
                }
                
            
        
        } else {
                
            DispatchQueue.main.async {
            
                [unowned self] in
                
            if self.statusItem.title != nil {
            
            self.statusItemIsEmpty = true
            self.statusItem.attributedTitle = nil
            self.statusItem.image = self.icon
                
            }
                
            }
            
            
            
        }
        
    }
            
    }
    
    func doStatusItemAlert(with strings: [String]) {
        
        let waitTime = 1.5
        // Set how long each text item should show.
        
        if HLLDefaults.statusItem.mode != .Off {
        
        DispatchQueue.main.async {
            
            self.doingStatusItemAlert = true
            let items = strings
    
            var scheduledCycle = 0.0
                
                for item in items {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + scheduledCycle) {
                        
                        let myAttrString = NSAttributedString(string: item, attributes: self.SIAttribute)
                        
                            self.statusItem.image = nil
                            self.statusItem.attributedTitle = myAttrString
                    }
                    
                    scheduledCycle += waitTime
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + scheduledCycle) {
                    self.doingStatusItemAlert = false
                    self.main.updateCalendarData(doGlobal: false)
                }
                
            }
            
            }
        }
    
    
    let currentEventRowsQueue = DispatchQueue(label: "AddCurrentRows")
    
    func setTopShelfItems(_ items: [EventMenuItem]) {
        
        var currentCount = 0
    
        for item in items {
        
            if item.type == .current {
            
                currentCount += 1
            }
    
        }
        
        if currentCount < 2 {
            
            EventCache.primaryEvent = nil
            
        }
        
        for item in self.arrayOfCurrentEventMenuItems {
            self.mainMenu.removeItem(item)
        }
        
        self.arrayOfCurrentEventMenuItems.removeAll()
        currentEventWindowButtons.removeAll()
        
        if self.inNoAccessMode {
        return
    }
        
    for eventMenuItem in items.reversed() {
        
        let menuItem = eventMenuItem.item
        
        if let event = eventMenuItem.event {
            
            let submenu = EventInfoSubmenuGenerator.shared.generateSubmenuContentsFor(event: event)
            
            if eventMenuItem.type == .current, event.completionStatus == .InProgress {
                
                submenu.addItem(NSMenuItem.separator())
                let windowButton : NSMenuItem = NSMenuItem()
                windowButton.title = "Open Countdown Window..."
                windowButton.action = #selector(self.countdownWindowButtonClicked(sender:))
                windowButton.target = self
                windowButton.isEnabled = true
                currentEventWindowButtons[windowButton] = event
                submenu.addItem(windowButton)
                
                menuItem.action = #selector(self.currentEventMenuItemClicked(sender:))
                menuItem.target = self
                menuItem.isEnabled = true
                self.countdownMenuItemEvents[menuItem] = event
                
            }
            
            menuItem.submenu = submenu
        
            if let primaryEvent = EventCache.primaryEvent {
                    
                if event == primaryEvent, items.count > 1 {
                        
                    menuItem.state = .on
                    
                }
                
            }
            
        }
        
        self.arrayOfCurrentEventMenuItems.append(menuItem)
        self.mainMenu.insertItem(menuItem, at: 0)
        
    }
        
    }
    
    func updateExistingCurrentEventRows(with strings: [(String, String?, HLLEvent?, HLLEvent?)]) {
        
        for string in strings {
            
            
            for item in countdownMenuItemEvents {
                
                if item.value == string.2 {
                    
                    var text = string.0
                    
                    if let percent = string.1 {
                        
                        text += " \(percent)"
                        
                    }
                    
                    
                    item.key.title = text
                    
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    var EventUIWindowControllers = [String:NSWindowController]()
    var EventUIStoryboard = NSStoryboard(name: "EventUIStoryboard", bundle: nil)
    
    @objc func countdownWindowButtonClicked(sender: NSMenuItem) {
        
        if let event = currentEventWindowButtons[sender] {
            
            var id: String
            
            if let ekID = event.EKEvent?.eventIdentifier {
                
                id = ekID
                
            } else {
                
                id = event.identifier
                
            }
            
            if let window = EventUIWindowControllers[id] {
                
                NSApp.activate(ignoringOtherApps: true)
                window.window?.delegate = self
                window.showWindow(self)
                
            } else {
            
            let vc = self.EventUIStoryboard.instantiateController(withIdentifier: "MainUI") as? NSWindowController
            vc?.window?.delegate = self
                
                
            (vc!.contentViewController?.children.first as! EventUITabViewController).event = event
            
            EventUIWindowControllers[id] = vc
            
            if let window = EventUIWindowControllers[id] {
                
                NSApp.activate(ignoringOtherApps: true)
                window.window?.delegate = self
                window.showWindow(self)

                
            }
            
            }
            
        } else {
            
            print("No match")
            
        }
        
        
    }
    
    @objc func currentEventMenuItemClicked(sender: NSMenuItem) {
        
        if sender.state == .on {
            
            EventCache.primaryEvent = nil
            
            
        } else {

            if let eventForSender = countdownMenuItemEvents[sender], let selected = EventCache.primaryEvent {
            
            if selected == eventForSender {
                
                sender.state = .off
                
            } else {
                
                clickedID = countdownMenuItemEvents[sender]
                EventCache.primaryEvent = self.countdownMenuItemEvents[sender]
                
            }
            
            
        } else {
                
                clickedID = countdownMenuItemEvents[sender]
                EventCache.primaryEvent = self.countdownMenuItemEvents[sender]
                
            
        }
        
    }
        
        self.main.mainRunLoop()
        
    }
    
    func updateNextEventItem(text: String?) {
        
        if let unwrappedText = text {
         upcomingEventsRow.title = unwrappedText
            
        }
        
    }
    
    func updateTermDataMenu(termData: TermData?) {
        
        termRow.isHidden = true
        
        if let data = termData, HLLDefaults.magdalene.doHolidays == true, data.onNow == false {
            
            let submenu = NSMenu()
            
            for item in data.topRow {
                
                let menuItem = NSMenuItem()
                menuItem.title = item
                menuItem.isEnabled = false
                submenu.addItem(menuItem)
                
            }
            submenu.addItem(NSMenuItem.separator())
            
            for item in data.submenuItems {
                
                let menuItem = NSMenuItem()
                menuItem.title = item
                menuItem.isEnabled = false
                submenu.addItem(menuItem)
                
            }
            
            termRow.title = data.menuString
            termRow.submenu = submenu
            termRow.isHidden = false
            
        } else {
            
            termRow.isHidden = true
            
        }
        
        
        
        
    }
    
    
    func updateUpcomingEventsMenu(data: upcomingDayOfEvents?) {
        
        if HLLDefaults.general.showNextEvent == false {
            upcomingEventsRow.isHidden = true
            return
        } else {
            upcomingEventsRow.isHidden = false
        }
        
        
        if let safeData = data {
            
        
        if safeData.eventStrings.isEmpty == true {
            
            upcomingEventsRow.isHidden = true
            return
        }
        

        upcomingEventsMenu.removeAllItems()
            
            if safeData.headerStrings.isEmpty == false {
                
                for item in safeData.headerStrings {
                    
                    let menuItem : NSMenuItem = NSMenuItem()
                    
                    menuItem.title = item
                    
                        menuItem.isEnabled = false

                    
                    upcomingEventsMenu.addItem(menuItem)
                    
                    
                    
                }
                
                
            }
            
            
            let topSep = NSMenuItem.separator()
            upcomingEventsMenu.addItem(topSep)
            
            for (index, itemData) in safeData.HLLEvents.enumerated() {
            
            let item = safeData.eventStrings[index]
            let event = itemData
            
            let menuItem : NSMenuItem = NSMenuItem()
            
            menuItem.submenu = EventInfoSubmenuGenerator.shared.generateSubmenuContentsFor(event: event)
            menuItem.title = item
                
                switch event.completionStatus {
                    
                case .NotStarted:
                    menuItem.state = .off
                case .InProgress:
                    menuItem.state = .mixed
                case .Done:
                    menuItem.state = .on
                }
            
            upcomingEventsMenu.addItem(menuItem)
            
        }
        
            
            let bottomSep = NSMenuItem.separator()
            upcomingEventsMenu.addItem(bottomSep)
            
            if safeData.footerStrings.isEmpty == false {
                
                for item in safeData.footerStrings {
                    
                    let menuItem : NSMenuItem = NSMenuItem()
                    
                    menuItem.title = item
                    
                    menuItem.isEnabled = false
                    
                    
                    upcomingEventsMenu.addItem(menuItem)
                    
                    
                    
                }
                
                
            }
            
        upcomingEventsRow.isEnabled = !safeData.HLLEvents.isEmpty
        
        } else {
            
            upcomingEventsRow.isHidden = true
            return
            
        }
    }
    
    func updateUpcomingWeekMenu(data: [upcomingDayOfEvents]) {
        
        if HLLDefaults.general.showUpcomingEventsSubmenu == false {
            upcomingFutureRow.isHidden = true
            return
        } else {
            upcomingFutureRow.isHidden = false
        }
        
        if data.isEmpty == true {
            
           upcomingFutureRow.isHidden = true
            
        }
        
        upcomingFutureMenu.removeAllItems()
        
        for (dataIndex, item) in data.enumerated() {
            
            
            
            let eventsSubmenu = NSMenu()
            
            for (index, eventString) in item.eventStrings.enumerated() {
                
                let event = item.HLLEvents[index]
                
                let menuItem : NSMenuItem = NSMenuItem()
                
                switch event.completionStatus {
                    
                  
                case .NotStarted:
                  //  doneStatus = ""
                    break
                case .InProgress:
                   // doneStatus = "- In Progress"
                    menuItem.state = .mixed
                case .Done:
                  //  doneStatus = "- Done"
                    menuItem.state = .on
                }
                
                menuItem.title = "\(String(eventString))"
                
                menuItem.submenu = EventInfoSubmenuGenerator.shared.generateSubmenuContentsFor(event: event)
                
                eventsSubmenu.addItem(menuItem)
                
            }
            
            let dayMenuItem : NSMenuItem = NSMenuItem()
            dayMenuItem.title = item.menuTitle
            dayMenuItem.submenu = eventsSubmenu
            dayMenuItem.isEnabled = !item.eventStrings.isEmpty
            
            upcomingFutureMenu.addItem(dayMenuItem)
            
            if data.indices.contains(dataIndex+1) {
                
                if data[dataIndex].menuTitle.contains("Sunday"), data[dataIndex+1].menuTitle.contains("Monday") {
                    
                 
                    
                }
                
            }
            
            
            if dataIndex == 0 {
                
               let seperator = NSMenuItem.separator()
               upcomingFutureMenu.addItem(seperator)
                
            }
            
        }
    }
    
    
    func addHolidaysCountToRow(string: String?) {
        
        if let countToString = string {
            
            holidaysCountToRow.isHidden = false
            holidaysCountToRow.title = countToString
            
            
        } else {
            
            holidaysCountToRow.isHidden = true
            
        }
        
    }
    
    func noCalendarAccessUIState(enabled: Bool) {
        
      //  nextEventRow.isHidden = enabled
       // upcomingEventsRow.isHidden = enabled
        
        if enabled == true {
            inNoAccessMode = true
            updateStatusItem(with: "⚠️")
            
            
            
        } else {
          inNoAccessMode = false
            
        }
        
    }
    
    
    @IBAction func fixClicked(_ sender: NSMenuItem) {
        
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"),
            
            NSWorkspace.shared.open(url) {
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NSWorkspace.shared.launchApplication("System Preferences")
        }
        
    }
    
    func setUpdateAvaliableState(version: String?) {
        
        if let unwrappedVersion = version {
            
            updateAvaliableItem.isHidden = false
            updateAvaliableItem.title = "An update is avaliable... (V\(unwrappedVersion))"
            
            
        } else {
            
            updateAvaliableItem.isHidden = true
            
        }
        
    }
    
    @IBAction func updateAvaliableClicked(_ sender: NSMenuItem) {
        
        if let url = URL(string: "macappstore://showUpdatesPage") {
            NSWorkspace.shared.open(url)
            print("default browser was successfully opened")
        }
    }
    
    static var preferencesWindowController: PreferencesWindowController?
    
    @IBAction func preferencesButtonClicked(_ sender: NSMenuItem) {
        
       launchPreferences()
        
    }
    
    var vcs = [Preferenceable]()
    
    func launchPreferences() {
        
        autoreleasepool {
        
            
            vcs.removeAll()
        
            vcs.append(GeneralPreferenceViewController())
            
            vcs.append(StatusItemPreferenceViewController())

            
            
        if EventDataSource.accessToCalendar == .Denied {
            
            vcs.append(CalendarPreferenceViewControllerNoAccess())
            
        } else {
            
            vcs.append(CalendarPreferenceViewController())
            
        }
        
        vcs.append(NotificationPreferenceViewController())
        
        if SchoolAnalyser.privSchoolMode == .Magdalene {
            
            vcs.append(MagdalenePreferenceViewController())
            vcs.append(RenamePreferenceViewController())
            
        }
    
        
        vcs.append(aboutViewController())
        
        MenuController.preferencesWindowController?.window?.close()
        
        MenuController.preferencesWindowController = PreferencesWindowController (
            viewControllers: vcs
        )
        
        MenuController.preferencesWindowController?.window?.delegate = self
        MenuController.preferencesWindowController?.window?.title = "How Long Left Preferences"
        MenuController.preferencesWindowController?.showWindow()
        
        
        
        
        }
        
    }
    
    @IBAction func aboutClicked(_ sender: NSMenuItem) {
        
        launchPreferences()
        
    }
    
    
    @IBAction func quitClicked(_ sender:
        NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        
        for keyValue in EventUIWindowControllers {
            
            
            if keyValue.value == sender.windowController! {
                
                EventUIWindowControllers.removeValue(forKey: keyValue.key)
                
            }
            
        }
        
        if sender == MenuController.preferencesWindowController?.window {
            
    
            MenuController.preferencesWindowController = nil
            vcs.removeAll()
            
        }
        
        return true
        
    }
    

}