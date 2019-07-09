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

class UIController: NSObject, HLLMacUIController, NSMenuDelegate, NSWindowDelegate {
    
    static var shared: UIController?

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
    lazy var main = Main(aDelegate: self as HLLMacUIController)
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
        UIController.shared = self
        
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
        UIController.menuIsOpen = false
            self.main.mainRunLoop()
            
            
        }
        
    }
    

    
    
    func menuWillOpen(_ menu: NSMenu) {
        
        
        if menu == mainMenu {
           UIController.menuIsOpen = true
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
    
    
   func addCurrentEventRows(with strings: [(String, String?, HLLEvent?, HLLEvent?)], updateNextOccurs: Bool) {
    currentEventWindowButtons.removeAll()
    
    var setEvents = [HLLEvent]()
    var callEvents = [HLLEvent]()
    
    for event in countdownMenuItemEvents.values {
        
        setEvents.append(event)
        
        
    }
    
    for item in strings {
        
        if let event = item.2 {
            
            callEvents.append(event)
            
        }
        
    }
    
        for item in self.arrayOfCurrentEventMenuItems {
            self.mainMenu.removeItem(item)
        }
        
        self.arrayOfCurrentEventMenuItems.removeAll()
        self.countdownMenuItemEvents.removeAll()
    
        if self.inNoAccessMode {
        return
    }
    
    var matchedEvent = false
    
    if strings.count == 1 {
        EventCache.primaryEvent = nil
        
        if strings[0].2 == nil {
            
            let menuItem : NSMenuItem = NSMenuItem()
            menuItem.title = "No events are on right now."
            menuItem.isEnabled = false
            arrayOfCurrentEventMenuItems.append(menuItem)
            self.mainMenu.insertItem(menuItem, at: 0)
            return
            
        }
        
        
    }   
    
    for data in strings.reversed() {
            
            var titleString = data.0
            
            if let percentText = data.1 {
                
                titleString += " \(percentText)"
                
            }
        
            let submenu = NSMenu()
        
        let menuItem : NSMenuItem = NSMenuItem()
        menuItem.title = titleString
        
        if let cEvent = data.2 {
            
        
            let subData = EventInfoSubmenuGenerator.shared.generateSubmenuContentsFor(event: cEvent)
            
            for (iN, arrayItem) in subData.enumerated() {
        
            for subArrayItem in arrayItem {
            
                let smenuItem : NSMenuItem = NSMenuItem()
                smenuItem.title = subArrayItem
                submenu.addItem(smenuItem)
                
                }
                
                
                    
                            
                
                
                if subData.indices.contains(iN+1) {
            
            let sep = NSMenuItem.separator()
            submenu.addItem(sep)
                    
                }
                
                

            
            
        }
            
            if let nextOccur = data.3, let item = nextOccurGen.generateNextOccurenceItems(events: [nextOccur]).first {
                
                
                // let index = mainMenu.index(of: nextOccurRow)
                let row = NSMenuItem(title: "\(item.0)", action: nil, keyEquivalent: "")
                
                if item.1.isEmpty == false {
                    
                    let NXOsubmenu = NSMenu()
                    
                    for (index, submenuItemText) in item.1.enumerated() {
                        
                        if index == 2 {
                            NXOsubmenu.addItem(NSMenuItem.separator())
                        }
                        
                        let submenuItem = NSMenuItem()
                        submenuItem.title = submenuItemText
                        submenuItem.isEnabled = false
                        NXOsubmenu.addItem(submenuItem)
                        
                    }
                    
                    row.submenu = NXOsubmenu
                    row.isEnabled = true
                    
                } else {
                    
                    row.isEnabled = false
                    
                }
                
                nextOccurMenuItems.append(row)
                
                
                submenu.addItem(NSMenuItem.separator())
                
                submenu.addItem(row)
                
            }
            
            submenu.addItem(NSMenuItem.separator())
            
            let windowButton : NSMenuItem = NSMenuItem()
            windowButton.title = "Open Countdown Window..."
            
            windowButton.action = #selector(self.countdownWindowButtonClicked(sender:))
            windowButton.target = self
            windowButton.isEnabled = true
            
            
            currentEventWindowButtons[windowButton] = cEvent
            
            submenu.addItem(windowButton)
            
        menuItem.submenu = submenu
        
        if strings.count != 1 {
            
            menuItem.action = #selector(self.currentEventMenuItemClicked(sender:))
            menuItem.target = self
            menuItem.isEnabled = true
            
        } else {
            
           // menuItem.isEnabled = false
        }
        
            if let event = EventCache.primaryEvent {
            
                
                if let rowEvent = data.2 {
                    
                    if rowEvent == event, strings.count > 1 {
                        
                        menuItem.state = .on
                        matchedEvent = true
                    }
                    
                }
                
                
            }
            
            
        self.mainMenu.insertItem(menuItem, at: 0)
            
            if let event = data.2 {
               
                self.countdownMenuItemEvents[menuItem] = event
                
            }
            
            
        self.arrayOfCurrentEventMenuItems.append(menuItem)
            
        }
        
    }
    
    if matchedEvent == false {
        
      //  EventCache.primaryEvent = EventCache.currentEvents.first
        
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
    
    var MainUIWindowControllers = [String:NSWindowController]()
    var MainUIStoryboard = NSStoryboard(name: "HLLMainUIStoryboard", bundle: nil)
    
    @objc func countdownWindowButtonClicked(sender: NSMenuItem) {
        
        if let event = currentEventWindowButtons[sender] {
            
            var id: String
            
            if let ekID = event.EKEvent?.eventIdentifier {
                
                id = ekID
                
            } else {
                
                id = event.identifier
                
            }
            
            if let window = MainUIWindowControllers[id] {
                
                NSApp.activate(ignoringOtherApps: true)
                window.window?.delegate = self
                window.showWindow(self)
                
            } else {
            
            let vc = self.MainUIStoryboard.instantiateController(withIdentifier: "MainUI") as? NSWindowController
            vc?.window?.delegate = self
            (vc!.contentViewController as! MainUIViewController).event = event
            
            MainUIWindowControllers[id] = vc
            
            if let window = MainUIWindowControllers[id] {
                
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
            
            let submenuMenu = NSMenu()
            
            
                
            let items = EventInfoSubmenuGenerator.shared.generateSubmenuContentsFor(event: event)
            
            for (iN, arrayItem) in items.enumerated() {
                
                for subArrayItem in arrayItem {
                    
                    let smenuItem : NSMenuItem = NSMenuItem()
                    smenuItem.title = subArrayItem
                    
                    submenuMenu.addItem(smenuItem)
                }
                
                
                if items.indices.contains(iN+1) {
                    
                    let sep = NSMenuItem.separator()
                    submenuMenu.addItem(sep)
                    
                }
                
                
                
                
            }
            
            menuItem.submenu = submenuMenu
            
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
                
               let submenuMenu = NSMenu()
                
               let items = EventInfoSubmenuGenerator.shared.generateSubmenuContentsFor(event: event)
                
                for (iN, arrayItem) in items.enumerated() {
                    
                    for subArrayItem in arrayItem {
                        
                        let smenuItem : NSMenuItem = NSMenuItem()
                        smenuItem.title = subArrayItem
                        
                        submenuMenu.addItem(smenuItem)
                    }
                    
                    
                    if items.indices.contains(iN+1) {
                        
                        let sep = NSMenuItem.separator()
                        submenuMenu.addItem(sep)
                        
                    }
                    
                    
                    
                    
                }
                
                
                menuItem.submenu = submenuMenu
                
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
        
        UIController.preferencesWindowController?.window?.close()
        
        UIController.preferencesWindowController = PreferencesWindowController (
            viewControllers: vcs
        )
        
        UIController.preferencesWindowController?.window?.delegate = self
        UIController.preferencesWindowController?.window?.title = "How Long Left Preferences"
        UIController.preferencesWindowController?.showWindow()
        
        
        
        
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
        
        
        for keyValue in MainUIWindowControllers {
            
            
            if keyValue.value == sender.windowController! {
                
                MainUIWindowControllers.removeValue(forKey: keyValue.key)
                
            }
            
        }
        
        if sender == UIController.preferencesWindowController?.window {
            
    
            UIController.preferencesWindowController = nil
            vcs.removeAll()
            
        }
        
        return true
        
    }
    

}
