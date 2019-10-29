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

class MenuController: NSObject, NSMenuDelegate, NSWindowDelegate {
    
    static var shared: MenuController?
    var menuCloseTimer: Timer?
    var windowVisTimer: Timer?
    static var awokeAt: Date?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let SIAttribute = [ NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 14.0)!]
    let basicIcon = NSImage(named: "statusIcon")!
    let colourIcon = NSImage(named: "ColourSI")!
    
    @IBOutlet weak var selectionTipMenuItem: NSMenuItem!
    
    var useColour = true
    
    var icon: NSImage {
        
        get {
            
            if HLLDefaults.statusItem.appIconStatusItem {
                
                return colourIcon
                
            } else {
                
                return basicIcon
                
            }
            
            
        }
        
        
    }
    
    var SITemplate: Bool {
        
        get {
            
            if HLLDefaults.statusItem.appIconStatusItem {
                
                return false
                
            } else {
                
                return true
                
            }
            
            
        }
        
        
    }
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var upcomingFutureRow: NSMenuItem!
    @IBOutlet weak var upcomingFutureMenu: NSMenu!
    @IBOutlet weak var noCalAccessInfo: NSMenuItem!
    @IBOutlet weak var noCalAccessButton: NSMenuItem!
    @IBOutlet weak var edvalButton: NSMenuItem!
    @IBOutlet weak var appInfoRow: NSMenuItem!
    @IBOutlet weak var updateAvaliableItem: NSMenuItem!
    @IBOutlet weak var termRow: NSMenuItem!
    @IBOutlet weak var termMenu: NSMenu!
    static var menuIsOpen = false
    var inNoAccessMode = false
    lazy var main = HLLMain(aDelegate: self)
    let version = Version()
    var topShelfItems = [NSMenuItem]()
    var doingStatusItemAlert = false
    var currentStatusItemText: String?
    var statusItemIsEmpty = false
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
        
        self.statusItem.isVisible = true
        self.statusItem.button?.imagePosition = .imageLeft
        
        DispatchQueue.main.async {
        
        MenuController.shared = self
        
            
           // self.statusItem.behavior = .
            
            self.main = HLLMain(aDelegate: self)
        print("SA5")
        
            let currentVersion = Version.currentVersion
        
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
            if #available(OSX 10.14, *) {
            
                self.statusItem.button?.image = self.icon
            
            } else {
                
                self.statusItem.image = self.icon
                
            }
            self.appInfoRow.title = "How Long Left \(currentVersion) (\(build!))"
            self.statusItem.menu = self.mainMenu
            self.icon.isTemplate = self.SITemplate
            self.mainMenu.removeItem(at: 0)
            self.mainMenu.delegate = self as NSMenuDelegate
            
        }
        
    }
    
    func menuDidClose(_ menu: NSMenu) {
        
        if menu == mainMenu {
        MenuController.menuIsOpen = false
            self.main.mainRunLoop()
            
            
        }
        
    }
    
    
    @IBAction func clearSelected(_ sender: NSMenuItem) {
        
        SelectedEventManager.selectedEvent = nil
        
    }
    
    
    func menuWillOpen(_ menu: NSMenu) {
        
        if menu == mainMenu {
           MenuController.menuIsOpen = true
            
            main.runMainMenuUIUpdate(checkOpen: true)
            
          
            
            let key = "ShownSelectionTip"
            
            
            if HLLDefaults.defaults.bool(forKey: key) {
                
                selectionTipMenuItem.isHidden = true
                
            } else {
                
                HLLDefaults.defaults.set(true, forKey: key)
                selectionTipMenuItem.isHidden = false
                
            }
            
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
            
            if HLLEventSource.accessToCalendar == .Denied {
            
                noCalAccessInfo.isHidden = false
                noCalAccessButton.isHidden = false
                
            } else {
                
                noCalAccessInfo.isHidden = true
                noCalAccessButton.isHidden = true
                
            }
            
            
            
            
            upcomingFutureRow.isHidden = true
            
            if HLLDefaults.calendar.enabledCalendars.isEmpty || HLLEventSource.accessToCalendar == .Denied {
                
                 upcomingFutureRow.isHidden = true
                
            } else if HLLDefaults.general.showUpcomingWeekMenu {
                
                upcomingFutureRow.isHidden = false
                
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
    
    func updateStatusItem(with text: String?, selected: Bool = false) {
        
        
        if self.doingStatusItemAlert == false {
        
        if let unwrappedText = text, HLLDefaults.statusItem.mode != .Off {
            
                DispatchQueue.main.async {
                    
                    [unowned self] in
                    
                    if selected {
                        
                        if #available(OSX 10.14, *) {
                        
                            self.statusItem.button?.image = NSImage(named: NSImage.menuOnStateTemplateName)
                            
                        } else {
                            
                            self.statusItem.image = NSImage(named: NSImage.menuOnStateTemplateName)
                            
                            
                        }
                        
                        self.icon.isTemplate = true
                        
                    } else {
                        
                        if #available(OSX 10.14, *) {
                        
                            self.statusItem.button?.image = nil
                            
                        } else {
                            
                            self.statusItem.image = nil
                            
                        }
                        self.icon.isTemplate = self.SITemplate
                        
                    }
                    
                if #available(OSX 10.14, *) {
                
                    self.statusItem.button?.attributedTitle = NSAttributedString(string: unwrappedText, attributes: self.SIAttribute)
                
                } else {
                    
                    self.statusItem.attributedTitle = NSAttributedString(string: unwrappedText, attributes: self.SIAttribute)

                }
                    
                    self.currentStatusItemText = unwrappedText
                    self.statusItemIsEmpty = false
                    
                }
        
        } else {
                
            DispatchQueue.main.async {
            
                [unowned self] in
                
            if #available(OSX 10.14, *) {
                
                if self.statusItem.button?.title != nil {
            
                self.statusItemIsEmpty = true
                self.statusItem.button?.title = ""
                self.statusItem.button?.image = self.icon
                self.icon.isTemplate = self.SITemplate
                
            }
                
        } else {
                
            if self.statusItem.title != nil {
                
                self.statusItemIsEmpty = true
                self.statusItem.attributedTitle = nil
                self.statusItem.image = self.icon
                self.icon.isTemplate = self.SITemplate
                    
        }
                
        }
                
            }
            
            
            
        }
        
    }
            
    }
    
    var currentAlertRequestDate = Date()
    
    func doStatusItemAlert(with strings: [String], showEachItemFor: Double = 1.5) {
        
        // Set how long each text item should show.
        let requestDate = Date()
        currentAlertRequestDate = requestDate
        
        
        if HLLDefaults.statusItem.mode != .Off {
        
        DispatchQueue.main.async {
            
            self.doingStatusItemAlert = true
            let items = strings
    
            var scheduledCycle = 0.0
                
                for item in items {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + scheduledCycle) {
                        
                        if requestDate == self.currentAlertRequestDate {
                        
                        let attributedString = NSAttributedString(string: item, attributes: self.SIAttribute)
                        
                            if #available(OSX 10.14, *) {
                                
                                self.statusItem.button?.image = nil
                                self.statusItem.button?.isTransparent = self.SITemplate
                                self.statusItem.button?.attributedTitle = attributedString
                                
                            } else {
                                
                                self.statusItem.image = nil
                                self.icon.isTemplate = self.SITemplate
                                self.statusItem.attributedTitle = attributedString
                                
                            }
                            
                        }
                    }
                    
                    scheduledCycle += showEachItemFor
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + scheduledCycle) {
                    self.doingStatusItemAlert = false
                    self.main.mainRunLoop()
                }
                
            }
            
            }
        }
    
    
    let currentEventRowsQueue = DispatchQueue(label: "AddCurrentRows")
    
    func setTopShelfItems(_ items: [NSMenuItem]) {
        
        for menuItem in topShelfItems {
            self.mainMenu.removeItem(menuItem)
        }
        
        topShelfItems.removeAll()
        
        if inNoAccessMode {
            return
        }
        
        for menuItem in items.reversed() {
        topShelfItems.append(menuItem)
        self.mainMenu.insertItem(menuItem, at: 0)
        }
        
    }
        
    let eventMenuGen = EventListMenuGenerator()
    
    func updateUpcomingWeekMenu(with item: NSMenuItem) {
        
        upcomingFutureRow.title = item.title
        upcomingFutureRow.submenu = item.submenu
        upcomingFutureRow.isEnabled = item.isEnabled
        upcomingFutureRow.state = item.state
    }
    
    func noCalendarAccessUIState(enabled: Bool) {
        
      //  nextEventRow.isHidden = enabled
       // upcomingEventsRow.isHidden = enabled
        
        if enabled == true {
            inNoAccessMode = true
            updateStatusItem(with: "⚠️ No Cal Access")
            
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
        
          NSApp.activate(ignoringOtherApps: true)
            
            
            
            vcs.removeAll()
        
            vcs.append(GeneralPreferenceViewController())
            vcs.append(MenuPreferenceViewController())
            vcs.append(StatusItemPreferenceViewController())
            vcs.append(CalendarPreferenceViewController())
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
        
         MenuController.preferencesWindowController?.window?.collectionBehavior = [.fullScreenNone]
        
        
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
        
        if sender == MenuController.preferencesWindowController?.window {
            
            MenuController.preferencesWindowController = nil
            vcs.removeAll()
            
        }
        
        return true
        
    }
    

}
