//
//  SchoolAnalyser.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolAnalyser {
    
    static let shared = SchoolAnalyser()
    static var doneAnalysis = false
    static var isRenamerApp = false
    
    public private(set) static var privSchoolMode: SchoolMode = .None
     private var schoolModeChangedDelegates = [SchoolModeChangedDelegate]()
    
    static var schoolMode: SchoolMode {
        
        get {
            
            if HLLDefaults.magdalene.manuallyDisabled == false || isRenamerApp == true {
                
                return privSchoolMode
                
            } else {
                
                return .None
                
            }
            
        }
        
        
    }
    
    func addSchoolMOdeChangedDelegate<T>(delegate: T) where T: SchoolModeChangedDelegate, T: Equatable {
        schoolModeChangedDelegates.append(delegate)
    }
    
    func removeSchoolModeChangedDelegate<T>(delegate: T) where T: SchoolModeChangedDelegate, T: Equatable {
        for (index, schoolModeDelegate) in schoolModeChangedDelegates.enumerated() {
            if let schoolModeDelegate = schoolModeDelegate as? T, schoolModeDelegate == delegate {
                schoolModeChangedDelegates.remove(at: index)
                break
            }
        }
    }

    
    let calendarData = EventDataSource.shared
    
    func analyseCalendar() {                                                                                                                                                                                                                                                                                                                                                
        
        let previousSchoolMode = SchoolAnalyser.privSchoolMode
        
        // Checks recent events (in both the past and present) and determines if the user goes to Magdalene or is Lauren.
        
     
        
        // let isLauren = analyseForLauren(Events: events)
        let isMagdalene = self.analyseForMagdalene()
        
        if isMagdalene == true {
            
            // The user goes to Magdalene
            
            SchoolAnalyser.privSchoolMode = .Magdalene
            
        } else {
            
            SchoolAnalyser.privSchoolMode = .None
            
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
            
            print("School mode is now \(SchoolAnalyser.privSchoolMode.rawValue)")
            schoolModeChangedDelegates.forEach {
               $0.schoolModeChanged()
            }
        
        }
        
        SchoolAnalyser.doneAnalysis = true
        
        
        
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
    
    private func analyseForMagdalene() -> Bool {
        
        // Analyses calendar events and determines if the user goes to Magdalene or not.
        
        var searchDays = [Date]()
        
        searchDays.append(getWednesdayFromWeek(weekNumber: 46, previousYear: true))
        searchDays.append(getWednesdayFromWeek(weekNumber: 12, previousYear: false))
        searchDays.append(getWednesdayFromWeek(weekNumber: 36, previousYear: false))
        searchDays.append(getWednesdayFromWeek(weekNumber: 46, previousYear: false))
        
        let Events = self.calendarData.fetchEventsOnDays(days: searchDays)
        
        var returnVal = false
        
        var yrCondition = false
        var homeroomCondition = false
        var roomCondtion = false
        
        
        for event in Events {
            
            
                if event.originalTitle.range(of:"Yr") != nil {
                    yrCondition = true
                }
                
                if event.originalTitle.range(of:"Homeroom") != nil {
                    homeroomCondition = true
                }
                
                if let location = event.fullLocation, location.range(of:"Room:") != nil  {
                    roomCondtion = true
                }
            
            if yrCondition == true, roomCondtion == true {
                returnVal = true
              //  print("Breaking Magdalene analysis early")
                break
                
            } else {
                
                if roomCondtion == true, homeroomCondition == true {
                    
                    returnVal = true
                    break
                    
                } else {
                    
                    returnVal = false
                }
                
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
