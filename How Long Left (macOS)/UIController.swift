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

class UIController: NSObject, HLLMacUIController, NSMenuDelegate {
    
    static var awokeAt: Date?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let SIAttribute = [ NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 14.0)!]
    let icon = NSImage(named: "statusIcon")!
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var nextEventRow: NSMenuItem!
    
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
    @IBOutlet weak var buildInfoRow: NSMenuItem!
    
    var inNoAccessMode = false
    
    lazy var main = Main(aDelegate: self as HLLMacUIController)
    let version = Version()
    var arrayOfCurrentEventMenuItems = [NSMenuItem]()
    var arrayOfUpcomingEventMenuItems = [NSMenuItem]()
    var doingStatusItemAlert = false
    var currentStatusItemText: String?
    var statusItemIsEmpty = false
    var clickedID: HLLEvent?
    
    
    var countdownMenuItemEvents: [NSMenuItem: HLLEvent] = [:]
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
        
        main.mainRunLoop()
        
        SchoolAnalyser.shared.analyseCalendar()
       // main.mainRunLoop()
        
      //  UIController.awokeAt = Date()
        let currentVersion = version.currentVersion
        
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        appInfoRow.title = "How Long Left \(currentVersion) (\(build!))"
        
        buildInfoRow.title = "Built: \(compileDate.formattedDate()), \(compileDate.formattedTime())"
        
        
        
        statusItem.menu = mainMenu
        icon.isTemplate = true
        statusItem.image = icon
        mainMenu.removeItem(at: 0)
        mainMenu.delegate = self as NSMenuDelegate
        
    }
    
    func menuDidClose(_ menu: NSMenu) {
    }
    

    
    
    func menuWillOpen(_ menu: NSMenu) {
        
        if menu == mainMenu {
        main.runMainMenuUIUpdate()
            
            if SchoolAnalyser.schoolMode == .Magdalene, HLLDefaults.magdalene.showEdvalButton == true {
                
                edvalButton.isHidden = false
                
                
            } else {
                
                edvalButton.isHidden = true
                
            }
            
            if NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) {
                
                
                appInfoRow.isHidden = false
                
                if NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.command) {
                   buildInfoRow.isHidden = false
                } else {
                   buildInfoRow.isHidden = true
                    
                }
                
                
                
            } else {
                
                appInfoRow.isHidden = true
                buildInfoRow.isHidden = true
            }
            
            if EventDataSource.accessToCalendar == .Denied {
                
                nextEventRow.isHidden = true
                upcomingEventsRow.isHidden = true
                nextOccurRow.isHidden = true
                upcomingFutureRow.isHidden = true
                noCalAccessInfo.isHidden = false
                noCalAccessButton.isHidden = false
                
            } else {
                
                noCalAccessInfo.isHidden = true
                noCalAccessButton.isHidden = true
                
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
            
          /*  var cont = true
            
            if let unwrappedCurrent = currentStatusItemText {
            
          if unwrappedText == unwrappedCurrent {
                cont = false
            }
                
            } */
            
                DispatchQueue.main.async {
                    
                self.statusItem.image = nil
                self.statusItem.attributedTitle = NSAttributedString(string: unwrappedText, attributes: self.SIAttribute)
                self.currentStatusItemText = unwrappedText
                self.statusItemIsEmpty = false
                
                }
                
            
        
        } else {
                
            DispatchQueue.main.async {
            
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
    
   func addCurrentEventRows(with strings: [(String, String?, HLLEvent?)]) {
    
    currentEventRowsQueue.async(flags: .barrier) {
    
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
    }
    
   
    
    for data in strings.reversed() {
            
            var titleString = data.0
            
            if let percentText = data.1 {
                
                titleString += " \(percentText)"
                
            }
        
            let menuItem : NSMenuItem = NSMenuItem()
            menuItem.title = titleString
        
        
        if strings.count != 1 {
            
            menuItem.action = #selector(self.currentEventMenuItemClicked(sender:))
            menuItem.target = self
            menuItem.isEnabled = true
            
        } else {
            
            menuItem.isEnabled = false
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
    
    if matchedEvent == false {
        
      //  EventCache.primaryEvent = EventCache.currentEvents.first
        
    }
        
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
                EventCache.primaryEvent = countdownMenuItemEvents[sender]
                
            }
            
            
        } else {
                
                clickedID = countdownMenuItemEvents[sender]
                EventCache.primaryEvent = countdownMenuItemEvents[sender]
            
        }
        
    }
        
        self.main.mainRunLoop()
        
    }
    
    func updateNextEventItem(text: String?) {
        
        if let unwrappedText = text {
            nextEventRow.title = unwrappedText
            nextEventRow.isHidden = false
            
        } else {
            
            nextEventRow.isHidden = true
            
        }
        
        
        
    }
    
    func updateUpcomingEventsMenu(title: String, info: [String], events: [String]) {
        
        if HLLDefaults.general.showUpcomingEventsSubmenu == false {
            upcomingEventsRow.isHidden = true
            return
        } else {
            upcomingEventsRow.isHidden = false
        }
        
        if events.isEmpty == true {
            
            upcomingEventsRow.isHidden = true
            return
        }
        
        upcomingEventsRow.title = title

        upcomingEventsMenu.removeAllItems()
        
        for item in info {
            
            let menuItem : NSMenuItem = NSMenuItem()
            
            menuItem.title = item
            menuItem.isEnabled = false
            upcomingEventsMenu.addItem(menuItem)
            
        }
        
        let seperator = NSMenuItem.separator()
        upcomingEventsMenu.addItem(seperator)
        
        for item in events {
            
            let menuItem : NSMenuItem = NSMenuItem()
            
            menuItem.title = item
            
            if events.count > 1 {
              menuItem.isEnabled = true
            } else {
                menuItem.isEnabled = false
            }
            
            
            upcomingEventsMenu.addItem(menuItem)
            
        }
        
        upcomingEventsRow.isEnabled = !events.isEmpty
        
    }
    
    func updateUpcomingWeekMenu(data: [upcomingDayOfEvents]) {
        
        if HLLDefaults.general.showUpcomingEventsSubmenu == false {
            upcomingFutureRow.isHidden = true
            return
        } else {
            upcomingFutureRow.isHidden = false
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
                
              
                eventsSubmenu.addItem(menuItem)
                
            }
            
            let dayMenuItem : NSMenuItem = NSMenuItem()
            dayMenuItem.title = item.menuTitle
            dayMenuItem.submenu = eventsSubmenu
            dayMenuItem.isEnabled = !item.eventStrings.isEmpty
                
            
            
          //  upcomingFutureRow.isEnabled = !events.isEmpty
            
            upcomingFutureMenu.addItem(dayMenuItem)
            
            if dataIndex == 0 {
                
                let seperator = NSMenuItem.separator()
                upcomingFutureMenu.addItem(seperator)
                
            }
            
        }
    }
    
    
    func addNextOccurRows(items: [(String, [String])]) {
        
        for item in nextOccurMenuItems {
            
            mainMenu.removeItem(item)
            
        }
        
        nextOccurMenuItems.removeAll()
        
        if inNoAccessMode {
            return
        }
        
        
        for item in items {
            
            let index = mainMenu.index(of: nextOccurRow)
            let row = NSMenuItem(title: "\(item.0)", action: nil, keyEquivalent: "")
            
            if item.1.isEmpty == false {
            
            let submenu = NSMenu()
            
            for (index, submenuItemText) in item.1.enumerated() {
                
                if index == 2 {
                    submenu.addItem(NSMenuItem.separator())
                }
                
                let submenuItem = NSMenuItem()
                submenuItem.title = submenuItemText
                submenuItem.isEnabled = false
                submenu.addItem(submenuItem)
                
            }
                
                row.submenu = submenu
                row.isEnabled = true
                
            } else {
                
                row.isEnabled = false
                
            }
            
            nextOccurMenuItems.append(row)
            mainMenu.insertItem(row, at: index)
        
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
    
    
    
    static var preferencesWindowController = PreferencesWindowController (
        viewControllers: [
            GeneralPreferenceViewController(),
            StatusItemPreferenceViewController(),
            CalendarPreferenceViewController(), NotificationPreferenceViewController(), MagdalenePreferenceViewController()
        ]
    )
    
    
    @IBAction func preferencesButtonClicked(_ sender: NSMenuItem) {
        
        var vcs: [Preferenceable] = [
            GeneralPreferenceViewController(),
            StatusItemPreferenceViewController()
        ]
        
        if EventDataSource.accessToCalendar == .Denied {
            
            vcs.append(CalendarPreferenceViewControllerNoAccess())
            
        } else {
           
            vcs.append(CalendarPreferenceViewController())
            
        }
        
        vcs.append(NotificationPreferenceViewController())
        
        if SchoolAnalyser.privSchoolMode == .Magdalene {
            
            vcs.append(MagdalenePreferenceViewController())
            
        }
        
        
        
        UIController.preferencesWindowController.window?.close()
        
        UIController.preferencesWindowController = PreferencesWindowController (
            viewControllers: vcs
        )
        
        UIController.preferencesWindowController.window?.title = "How Long Left Preferences"
        UIController.preferencesWindowController.showWindow()
        
        
    }
    
    @IBAction func quitClicked(_ sender:
        NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

}
