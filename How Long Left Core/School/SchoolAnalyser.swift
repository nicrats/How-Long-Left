//
//  SchoolAnalyser.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

struct SchoolAnalyser {
    
    
    static var doneAnalysis = false
    static var isRenamerApp = false
    var delegate: SchoolModeChangedDelegate?
    static var termDates = [Date]()
    let searchWeeks = [46, 12, 24, 35, 46]
    public private(set) static var privSchoolMode: SchoolMode = .Unknown
    
    
    private var schoolModeChangedDelegates = [SchoolModeChangedDelegate]()
    static var schoolCalendar: EKCalendar?
    
    static var schoolMode: SchoolMode {
        
        get {
            
            if privSchoolMode == .Magdalene {
            
            if HLLDefaults.magdalene.manuallyDisabled == false {
                
                return privSchoolMode
                
            } else {
                
                return .None
                
            }
                
            } else {
                
                return privSchoolMode
                
            }
            
        }
        
        
    }
    
    static var isSchoolUser: Bool {
    
        get {
            
            if HLLDefaults.magdalene.manuallyDisabled == true {
                
                return false
                
            } else {
                
                if SchoolAnalyser.schoolMode == .Magdalene {
                    
                    return true
                    
                }
                
                return false
                
                
            }
            
        }
    
    
    }
    
    init() {
        
        if HLLDefaults.magdalene.magdaleneModeWasEnabled {
            
            SchoolAnalyser.privSchoolMode = .Magdalene
        }
        
        for (index, week) in searchWeeks.enumerated() {
            
            var doPreviousYear = false
            
            if index == 0 {
                
                doPreviousYear = true
                
            }
            
            SchoolAnalyser.termDates.append(getWednesdayFromWeek(weekNumber: week, previousYear: doPreviousYear))
            
        }
        
    }
    
    mutating func addSchoolMOdeChangedDelegate<T>(delegate: T) where T: SchoolModeChangedDelegate, T: Equatable {
        schoolModeChangedDelegates.append(delegate)
    }
    
    mutating func setLoneDelegate(to: SchoolModeChangedDelegate) {
        
        delegate = to
        
    }
    
    mutating func removeSchoolModeChangedDelegate<T>(delegate: T) where T: SchoolModeChangedDelegate, T: Equatable {
        for (index, schoolModeDelegate) in schoolModeChangedDelegates.enumerated() {
            if let schoolModeDelegate = schoolModeDelegate as? T, schoolModeDelegate == delegate {
                schoolModeChangedDelegates.remove(at: index)
                break
            }
        }
    }

    
    
    
    func analyseCalendar(inputEvents: [HLLEvent]) {
        
            
     
        let events = inputEvents.sorted(by: { $0.startDate.compare($1.startDate) == .orderedDescending })
        

        if events.isEmpty {
            
            SchoolAnalyser.privSchoolMode = .Unknown
            return
            
        }
        
        let isMagdalene = self.analyseForMagdalene(events: events)
        
        if isMagdalene == true {
            
            SchoolAnalyser.privSchoolMode = .Magdalene
            
        } else {
            SchoolAnalyser.privSchoolMode = .None
            
        }
        
        SchoolAnalyser.doneAnalysis = true
        
        
        
    }
    
    func getMagdaleneTitles(from: [HLLEvent], includeRenamed: Bool = false) -> [String] {
        
        var titles = [String]()
        
        let sorted = from.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        for event in sorted {
            
            if event.originalTitle.range(of:"Yr") != nil, let location = event.fullLocation, location.range(of:"Room:") != nil, titles.contains(event.originalTitle) == false {
                
                titles.append(event.originalTitle)
                
            }
            
            if event.originalTitle.range(of:"Study.") != nil || event.originalTitle.range(of:"SPORT:") != nil {
                
                titles.append(event.originalTitle)
                
            }
            
            if includeRenamed {
                
                if let notes = event.notes {
                    
                    if notes.contains(text: "Period:") {
                        
                        titles.append(event.originalTitle)
                        SchoolAnalyser.schoolCalendar = event.calendar
                        
                    }
                    
                }
                
            }
            
        }
        
        //print("GSMT: \(titles.count)")
        
        return titles
        
    }
    
    private func analyseForMagdalene(events: [HLLEvent]) -> Bool {
        
        // Analyses calendar events and determines if the user goes to Magdalene or not.
        
        var returnVal = false

        if events.isEmpty == false {
            returnVal = false
        }
        
        var periodCondition = false
        var roomCondtion = false
        
        let _ = self.getMagdaleneTitles(from: events, includeRenamed: true)
        
        for event in events.reversed() {
            
            if let location = event.fullLocation, location.range(of:"Room:") != nil  {
                roomCondtion = true
            }
            
            if let notes = event.notes {
                
                
                if notes.contains(text: "Period:") {
                    
                    periodCondition = true
                    
                }
                
                
            }
            
            if periodCondition, roomCondtion {
                
                returnVal = true
                
                break
            }
            
        }
        
        /*#if os(watchOS)
        
            print("Checking Watch MM")
            print("Defaults: \(HLLDefaults.magdalene.magdaleneModeWasEnabled)")
        
        
            if HLLDefaults.magdalene.magdaleneModeWasEnabled, returnVal == false {
                returnVal = true
            }
        
        returnVal = false
        
        #else
            
            print("Setting Magdalene mode default to \(returnVal)")
        
        
            HLLDefaults.magdalene.magdaleneModeWasEnabled = returnVal
            HLLDefaultsTransfer.shared.triggerDefaultsTransfer()
            print("Trig1")
        
        
        #endif*/
        
        #if targetEnvironment(simulator)
        returnVal = true
        #endif
        
        return returnVal
        
    }
    
    func getWednesdayFromWeek(weekNumber: Int, previousYear: Bool) -> Date {
        
        let calendar = NSCalendar.current
        var currentYear = calendar.component(.year, from: Date())
        
        if previousYear == true {
            
            currentYear -= 1
            
        }
        
        let Calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let dayComponent = NSDateComponents()
        dayComponent.weekOfYear = weekNumber
        dayComponent.weekday = 4
        dayComponent.year = currentYear
        var date = Calendar.date(from: dayComponent as DateComponents)
        
        if(weekNumber == 1 && Calendar.components(.month, from: date!).month != 1){
            dayComponent.year = currentYear-1
            date = Calendar.date(from: dayComponent as DateComponents)
        }
        
        return date!
    }
    
    func getNextSchoolSearchDate() -> Date {
        
        var upcomingDates = [Date]()
        for date in SchoolAnalyser.termDates {
            if date.timeIntervalSinceNow > 0 { upcomingDates.append(date) }
        }
        upcomingDates.sort(by: { $0.compare($1) == .orderedAscending })
        return upcomingDates.first!
        
    }
    
}

protocol SchoolModeChangedDelegate {
    func schoolModeChanged()
}
