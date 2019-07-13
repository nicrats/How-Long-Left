//
//  SchoolAnalyser.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

class SchoolAnalyser {
    
    static var calendarData = EventDataSource()
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
                
                if SchoolAnalyser.schoolMode == .Jasmine || SchoolAnalyser.schoolMode == .Magdalene {
                    
                    return true
                    
                }
                
                return false
                
                
            }
            
        }
    
    
    }
    
    init() {
        
        for (index, week) in searchWeeks.enumerated() {
            
            var doPreviousYear = false
            
            if index == 0 {
                
                doPreviousYear = true
                
            }
            
            SchoolAnalyser.termDates.append(getWednesdayFromWeek(weekNumber: week, previousYear: doPreviousYear))
            
        }
        
    }
    
    func addSchoolMOdeChangedDelegate<T>(delegate: T) where T: SchoolModeChangedDelegate, T: Equatable {
        schoolModeChangedDelegates.append(delegate)
    }
    
    func setLoneDelegate(to: SchoolModeChangedDelegate) {
        
        delegate = to
        
    }
    
    func removeSchoolModeChangedDelegate<T>(delegate: T) where T: SchoolModeChangedDelegate, T: Equatable {
        for (index, schoolModeDelegate) in schoolModeChangedDelegates.enumerated() {
            if let schoolModeDelegate = schoolModeDelegate as? T, schoolModeDelegate == delegate {
                schoolModeChangedDelegates.remove(at: index)
                break
            }
        }
    }

    
    
    
    func analyseCalendar(inputEvents: [HLLEvent]? = nil) {
        
        autoreleasepool {
        
        
        let schoolModeAtStart = SchoolAnalyser.privSchoolMode
        
       // let previousSchoolMode = SchoolAnalyser.privSchoolMode
        
        var events = [HLLEvent]()
        
        if let safeInput = inputEvents {
            
            events = safeInput
            
        } else {
            
            events = SchoolAnalyser.calendarData.fetchEventsOnDays(days: SchoolAnalyser.termDates)
            
        }

        if events.isEmpty {
            
            SchoolAnalyser.privSchoolMode = .Unknown
            return
            
        }
    
        if events.isEmpty == false {
        
        print("Doing school analysis on \(events.count) events, spanning \(events.first!.startDate.formattedDate()) to \(events.last!.startDate.formattedDate())")
            
        }
        
        // let isLauren = analyseForLauren(Events: events)
        let isMagdalene = self.analyseForMagdalene(events: events)
        let isJasmine = self.analyseForJasmine(events: events)
        
        if isMagdalene == true {
            
            SchoolAnalyser.privSchoolMode = .Magdalene
            
        } else if isJasmine == true {
            
            SchoolAnalyser.privSchoolMode = .Jasmine
            
        } else {
            
            SchoolAnalyser.privSchoolMode = .None
            
        }
        
        
            print("School mode is now \(SchoolAnalyser.privSchoolMode.rawValue)")
            
        if SchoolAnalyser.privSchoolMode != schoolModeAtStart {
        
        //delegate?.schoolModeChanged()
        
            
            /*schoolModeChangedDelegates.forEach {
               $0.schoolModeChanged()
            } */
        
        }
        
        SchoolAnalyser.doneAnalysis = true
        
        
        }
    }
    
    func getMagdaleneTitles(from: [HLLEvent]) -> [String] {
        
        var titles = [String]()
        
        for event in from {
            
            if event.originalTitle.range(of:"Yr") != nil, let location = event.fullLocation, location.range(of:"Room:") != nil, titles.contains(event.originalTitle) == false {
                
                titles.append(event.originalTitle)
                
            }
            
            if event.originalTitle.range(of:"Study.") != nil || event.originalTitle.range(of:"SPORT:") != nil {
                
                titles.append(event.originalTitle)
                
            }
            
        }
        
        return titles
        
    }
    
    private func analyseForMagdalene(events: [HLLEvent]) -> Bool {
        
        // Analyses calendar events and determines if the user goes to Magdalene or not.
        
        let sorted = events.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        SchoolAnalyser.schoolCalendar = sorted.last?.calendar
        print("School cal is \(SchoolAnalyser.schoolCalendar!.title)")
        
        var returnVal = false

        if events.isEmpty == false {
            
            returnVal = false
            
        }
       
        var renameIDCondition = false
        var yrCondition = false
        var roomCondtion = false
        var schoolStartCondition = false
        var schoolEndCondition = false
        
        for event in events {
            
            if event.originalTitle.range(of:"Yr") != nil {
                yrCondition = true
            }
            
            if let location = event.fullLocation, location.range(of:"Room:") != nil  {
                roomCondtion = true
            }
            
            if event.startDate.formattedTimeTwelve().lowercased() == "8:15am" {
                schoolStartCondition = true
            }
            
            if event.endDate.formattedTimeTwelve().lowercased() == "2:35pm" {
                schoolEndCondition = true
            }
            
            if let notes = event.notes {
                if notes.containsAnyOfThese(Strings: [RNSchoolIDStringStore.createdString, RNSchoolIDStringStore.renamedString]) {
                    renameIDCondition = true
                }
            }
            
            if renameIDCondition == true {
                returnVal = true
                break
            }
            
            if yrCondition == true, roomCondtion == true, schoolStartCondition == true, schoolEndCondition == true {
                returnVal = true
                break
            }
            
        }
        
       return returnVal
        
    }
    
    private func analyseForJasmine(events: [HLLEvent]) -> Bool {
        
        // Analyses calendar events and determines if the user is Jasmine or not.
        
        var returnVal = false
        
        
        if events.isEmpty == false {
            
            returnVal = false
            
        }
        
        var yrCondition = false
        var schoolStartCondition = false
        var schoolEndCondition = false
        
        for event in events {
            
            
            if event.originalTitle.range(of:"Yr") != nil {
                yrCondition = true
            }
            
            
            if event.startDate.formattedTimeTwelve().lowercased() == "9:00am" {
                
                schoolStartCondition = true
                
            }
            
            if event.endDate.formattedTimeTwelve().lowercased() == "3:15pm" {
                
                schoolEndCondition = true
                
            }
            
            if yrCondition == true, schoolStartCondition == true, schoolEndCondition == true {
                SchoolAnalyser.schoolCalendar = event.calendar
                returnVal = true
                break
                
            }
            
        }
        
        //  let analysisTime = Date().timeIntervalSince(analysisStart)
        

        
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
