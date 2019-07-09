//
//  HLLDefaults.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 27/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class HLLDefaults {

    static var shared = HLLDefaults()
    
    #if os(OSX)
    static var defaults = UserDefaults.init(suiteName: "5AMFX8X5ZN.howlongleft")!
    #elseif os(watchOS)
    static var defaults = UserDefaults.standard
    #else
    //static var cloudDefaults = NSUbiquitousKeyValueStore()
    static var defaults = UserDefaults(suiteName: "group.com.ryankontos.How-Long-Left")!
    #endif
    
    
    
    struct appData {
        
        
        static var launchedVersion: String? {
            
            get {
                
                
                return defaults.string(forKey: "launchedVersion")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "launchedVersion")
                
            }
            
            
        }
        
    }
    
    struct rename {
        
        static var promptToRename: Bool {
            
            
            get {
                
                return !defaults.bool(forKey: "RNDontPrompt")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "RNDontPrompt")
                
            }
            
            
            
            
        }
        
        
    }
    
    struct complication {
        
        
        static var largeCountdown: Bool {
            
                
                get {
                    
                    return defaults.bool(forKey: "largeCountdown")
                    
                }
                
                set (to) {
                    
                    defaults.set(to, forKey: "largeCountdown")
                    
                }
                
            
            
            
        }
        
        
        
    }
    
    struct general {
        
        static var showNextEvent: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideNext")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideNext")
                
            }
            
        }
        
        static var use24HourTime: Bool {
            
            get {
                
                return defaults.bool(forKey: "use24HrTime")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "use24HrTime")
                
            }
            
        }
        
        static var showUpcomingEventsSubmenu: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideUpcomingSubmenu")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideUpcomingSubmenu")
                
            }
            
        }
        
        static var showNextOccurItems: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideNextOccur")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideNextOccur")
                
            }
            
        }
        
        static var showPercentage: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hidePercentage")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hidePercentage")
                
            }
            
        }
        
        static var showLocation: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideLocation")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideLocation")
                
            }
            
        }
        
        static var showUpdates: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideUpdates")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideUpdates")
                
            }
            
        }
        
        
    }
    
    struct statusItem {
        
        static var mode: StatusItemMode {
            
            get {
                
                if let mode = StatusItemMode(rawValue: defaults.integer(forKey: "statusItemTimerMode")) {
                    
                    return mode
                    
                } else {
                    
                    return StatusItemMode.Timer
                    
                }
                
            }
            
            set (to) {
                
                defaults.set(to.rawValue, forKey: "statusItemTimerMode")
                
            }
            
        }
        
        static var showEndTime: Bool {
            
            get {
                
                return defaults.bool(forKey: "showStatusItemEndTime")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showStatusItemEndTime")
                
            }
            
        }
        
        static var showPercentage: Bool {
            
            get {
                
                return defaults.bool(forKey: "showStatusItemPercentage")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showStatusItemPercentage")
                
            }
            
        }
        
        static var showTitle: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideStatusItemTitle")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideStatusItemTitle")
                
            }
            
        }
        
        static var showLeftText: Bool {
            
            get {
                
                return defaults.bool(forKey: "showLeftText")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "showLeftText")
                
            }
            
        }
        
        static var doneAlerts: Bool {
            
            get {
                
                return !defaults.bool(forKey: "noDoneAlerts")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "noDoneAlerts")
                
            }
            
        }

        static var useFullUnits: Bool {
            
            get {
                
                return defaults.bool(forKey: "useFullUnits")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "useFullUnits")
                
            }
            
        }

        
        static var hideTimerSeconds: Bool {
            
            get {
                
                return defaults.bool(forKey: "hideTimerSecs")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "hideTimerSecs")
                
            }
            
        }

        
        
    }
    
    struct calendar {
        
        
        static var selectedCalendar: String? {
            
            get {
                
                return defaults.string(forKey: "selectedCalendar")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "selectedCalendar")
                
            }
            
        }
        
        static var enabledCalendars: [String] {
            
            get {
                
                return defaults.stringArray(forKey: "setCalendars") ?? [String]()
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "setCalendars")
                
            }
            
        }
        
        static var disabledCalendars: [String] {
            
            get {
                
                return defaults.stringArray(forKey: "disabledCalendars") ?? [String]()
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "disabledCalendars")
                
            }
            
        }
        
        
        static var useAllCalendars: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotUseAllCalendars")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotUseAllCalendars")
                
            }
            
        }
        
    }
    
    struct notifications {
        
        static var startNotifications: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotDoStartNotos")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotDoStartNotos")
                
            }
            
            
        }
        
        static var sounds: Bool {
            
            get {
                
                return defaults.bool(forKey: "useSounds")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "useSounds")
                
            }
            
            
        }
        
        static var hotkey: HLLHotKeyOption {
            
            get {
                
                if let hotKey = HLLHotKeyOption(rawValue: defaults.integer(forKey: "hotKey")) {
                    
                    return hotKey
                    
                } else {
                    
                    return HLLHotKeyOption.OptionW
                    
                }
                
            }
            
            set (to) {
                
                defaults.set(to.rawValue, forKey: "hotKey")
                
            }
            
        }
        
        static var milestones: [Int] {
            
            get {
                
                var returnArray = [Int]()
                
                if let hkArray = defaults.stringArray(forKey: "Milestones") {
                    
                    for item in hkArray {
                        
                        if let intItem = Int(item) {
                            
                            returnArray.append(intItem)
                            
                        }
                        
                    }
                    
                    return returnArray
                    
                    
                } else {
                    defaults.set(["600", "300", "60", "0"], forKey: "Milestones")
                    return [600, 300, 60, 0]
                    
                }
                
                
            }
            
            set (to) {
                
                var setArray = [String]()
                
                for item in to {
                    
                    setArray.append(String(item))
                    
                }
                
                defaults.set(setArray, forKey: "Milestones")
                
            }
            
            
        }
        
        static var Percentagemilestones: [Int] {
            
            get {
                
                var returnArray = [Int]()
                
                if let hkArray = defaults.stringArray(forKey: "PercentageMilestones") {
                    
                    for item in hkArray {
                        
                        if let intItem = Int(item) {
                            
                            returnArray.append(intItem)
                            
                        }
                        
                    }
                    
                    return returnArray
                    
                    
                } else {
                    defaults.set(["25", "50", "75"], forKey: "PercentageMilestones")
                    return [25, 50, 75]
                    
                }
                
                
            }
            
            set (to) {
                
                var setArray = [String]()
                
                for item in to {
                    
                    setArray.append(String(item))
                    
                }
                
                defaults.set(setArray, forKey: "PercentageMilestones")
                
            }
            
            
        }

        
    }
    
    struct magdalene {
        
        static var manuallyDisabled: Bool {
            
            get {
                
                return defaults.bool(forKey: "magdaleneFeaturesManuallyDisabled")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "magdaleneFeaturesManuallyDisabled")
                
            }
            
        }
        
        static var startTimeAdjusts: [String:[String:Int]]? {
            
            get {
                
                if let dict = defaults.dictionary(forKey: "magdaleneStartTimeAdjusts") as? [String:[String:Int]] {
                    
                    return dict
                    
                } else {
                    
                    return nil
                    
                }
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "magdaleneStartTimeAdjusts")
                
            }
            
        }
        
        static var endTimeAdjusts: [String:[String:Int]]? {
            
            get {
                
                if let dict = defaults.dictionary(forKey: "magdaleneEndTimeAdjusts") as? [String:[String:Int]] {
                    
                    return dict
                    
                } else {
                    
                    return nil
                    
                }
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "magdaleneEndTimeAdjusts")
                
            }
            
        }

        static var doDoubles: Bool {
            
            get {
                
               // return !defaults.bool(forKey: "doNotDoDoubles")
                return false
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotDoDoubles")
                
            }
            
        }
        
        static var shortenTitles: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotShortenTitles")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotShortenTitles")
                
            }
            
        }
        
        static var adjustTimes: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotAdjustTimes")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotAdjustTimes")
                
            }
            
        }
        
        static var showBreaks: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotShowBreaks")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotShowBreaks")
                
            }
            
        }
        
        static var doHolidays: Bool {
            
            get {
                
                return !defaults.bool(forKey: "doNotDoHolidays")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "doNotDoHolidays")
                
            }
            
        }
        
        static var doHolidaysInStatusItem: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideHolidaysInStatusItem")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideHolidaysInStatusItem")
                
            }
            
        }
        
        static var showHolidaysPercent: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideHolidaysPercent")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideHolidaysPercent")
                
            }
            
        }

        static var hideNonMagdaleneEvents: Bool {
            
            get {
                
                return defaults.bool(forKey: "hideNonMagdaleneEvents")
                
            }
            
            set (to) {
                
                defaults.set(to, forKey: "hideNonMagdaleneEvents")
                
            }
            
        }
        
        static var showEdvalButton: Bool {
            
            get {
                
                return !defaults.bool(forKey: "hideEdvalButton")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "hideEdvalButton")
                
            }
            
        }
        
        static var enableEdvalHotKey: Bool {
            
            get {
                
                return !defaults.bool(forKey: "disableEdvalHotKey")
                
            }
            
            set (to) {
                
                defaults.set(!to, forKey: "disableEdvalHotKey")
                
            }
            
        }

        
    }
        
  /*  func exportDefaultsToCloud() {
        
        for (key, value) in HLLDefaults.defaults.dictionaryRepresentation() {
            
            HLLDefaults.cloudDefaults.set(value, forKey: key)
            
        }
        
        HLLDefaults.cloudDefaults.synchronize()
        
        
    }
    
    func loadDefaultsFromCloud() {
        
        HLLDefaults.cloudDefaults.synchronize()
        
        for (key, value) in HLLDefaults.cloudDefaults.dictionaryRepresentation {
            
            
            HLLDefaults.defaults.set(value, forKey: key)
            
            
        }
        
        
        
    } */
    
    
    
    
}

