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
    
    static var doneAnalysis = false
    static var isRenamerApp = false
    var delegate: SchoolModeChangedDelegate?
    
    var searchDates = [Date]()
    let searchWeeks = [46, 12, 36, 46]
    
    public private(set) static var schoolModeIgnoringUserPreferences: SchoolMode = .Unknown
    private var schoolModeChangedDelegates = [SchoolModeChangedDelegate]()
    static var schoolCalendar: EKCalendar?
    
    static var schoolMode: SchoolMode {
        
        get {
            
            if schoolModeIgnoringUserPreferences == .Magdalene {
            
            if HLLDefaults.magdalene.manuallyDisabled == false {
                
                return schoolModeIgnoringUserPreferences
                
            } else {
                
                return .None
                
            }
                
            } else {
                
                return schoolModeIgnoringUserPreferences
                
            }
            
        }
        
        
    }
    
    init() {
        
        for (index, week) in searchWeeks.enumerated() {
            
            var doPreviousYear = false
            
            if index == 0 {
                
                doPreviousYear = true
                
            }
            
            searchDates.append(getWednesdayFromWeek(weekNumber: week, previousYear: doPreviousYear))
            
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

    
    let calendarData = EventDataSource()
    
    func analyseCalendar() {
        
        let previousSchoolMode = SchoolAnalyser.schoolModeIgnoringUserPreferences
        
        
        // let isLauren = analyseForLauren(Events: events)
        if let isMagdalene = self.analyseForMagdalene() {
            
            if isMagdalene == true {
                
               SchoolAnalyser.schoolModeIgnoringUserPreferences = .Magdalene
                
            } else {
                
                SchoolAnalyser.schoolModeIgnoringUserPreferences = .None
                
            }
            
        } else {
            
            SchoolAnalyser.schoolModeIgnoringUserPreferences = .Unknown
            
        }
        
        /* if isLauren == true {
         
         // The user is Lauren.
         
         SchoolAnalyser.schoolMode = .Lauren
         
         }
         
         if isLauren == true, isMagdalene == true {
         
         // Uh oh... The user goes to Magdalene and is also Lauren?! We'll set the schoolMode to "Conflict", and another part of the app can deal with this later.
         
         print("User is Both")
         
         SchoolAnalyser.schoolMode = .Conflict
         
         } */
        
        
       if SchoolAnalyser.schoolMode != previousSchoolMode {
        
        delegate?.schoolModeChanged()
        
            print("School mode is now \(SchoolAnalyser.schoolModeIgnoringUserPreferences.rawValue)")
            schoolModeChangedDelegates.forEach {
               $0.schoolModeChanged()
            }
        
        }
        
        SchoolAnalyser.doneAnalysis = true
        
        
        
    }
    
    private func analyseForMagdalene() -> Bool? {
        
        // Analyses calendar events and determines if the user goes to Magdalene or not.
        
        
        
        var returnVal: Bool?
        
        let Events = self.calendarData.fetchEventsOnDays(days: searchDates)
        
        if Events.isEmpty == false {
            
            returnVal = false
            
        }
        
        var yrCondition = false
        var roomCondtion = false
        var schoolStartCondition = false
        var schoolEndCondition = false
        
        for event in Events {
            
            
                if event.originalTitle.range(of:"Yr") != nil {
                    yrCondition = true
                }
            
                if let location = event.fullLocation, location.range(of:"Room:") != nil  {
                    roomCondtion = true
                }
            
                if event.startDate.formattedTime() == "8:15am" {
                    
                    schoolStartCondition = true
                
                }
            
                if event.endDate.formattedTime() == "2:35pm" {
                
                schoolEndCondition = true
                
                }
            
            if yrCondition == true, roomCondtion == true, schoolStartCondition == true, schoolEndCondition == true {
                SchoolAnalyser.schoolCalendar = event.calendar
                returnVal = true
                break
                
            }
            
        }
        
      //  let analysisTime = Date().timeIntervalSince(analysisStart)
        
        if Thread.isMainThread == true {
            
          //  print("School analysis took \(analysisTime)s on main thread")
            
        } else {
            
          //  print("School analysis took \(analysisTime)s on global thread")
            
        }
        
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
        for date in searchDates {
            if date.timeIntervalSinceNow > 0 { upcomingDates.append(date) }
        }
        upcomingDates.sort(by: { $0.compare($1) == .orderedAscending })
        return upcomingDates.first!
        
    }
    
    private func analyseForLauren(Events: [HLLEvent]) -> Bool {
     
     // Analyses calendar events and determines if the user is Lauren or not.
     // Might take this out since wE bRoKE uP. For now just commenting out Lauren stuff.
     // Move on lol
     
     var returnVal = false
     var matchableEvents = ["Xb","Break","Media","English","Leave the house","It","Enrichment"]
     var matchCounter = 0
     
     outer: for event in Events {
     
     if matchableEvents.contains(event.title) {
     
     matchCounter += 1
     
     if let index = matchableEvents.firstIndex(of: event.title) {
     
     matchableEvents.remove(at: index)
     
     }
     
     }
     
     if matchCounter > 1 {
     
     returnVal = true
     break outer
     
     }
     
     }
     
     return returnVal
        
     }
    
}

protocol SchoolModeChangedDelegate {
    func schoolModeChanged()
}
