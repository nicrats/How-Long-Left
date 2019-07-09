//
//  EventTimeAdjuster.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventTimeAdjuster {
   
    static let shared = EventTimeAdjuster()
    
    static var startTimeAdjusts = [String:[String:Int]]()
    static var endTimeAdjusts = [String:[String:Int]]()
    
    var updateTimer: Timer!
    
    
    init() {
        
     /*   if let defaultsStart = HLLDefaults.magdalene.startTimeAdjusts {
            
            print("Setting starts from stored defaults")
            EventTimeAdjuster.startTimeAdjusts = defaultsStart
            
        } else {
            
            print("Failed setting starts from stored defaults")
            
        }
        
        if let defaultsEnd = HLLDefaults.magdalene.endTimeAdjusts {
            
            EventTimeAdjuster.endTimeAdjusts = defaultsEnd
            print("Setting ends from stored defaults")
            
        } else {
            
            print("Failed setting ends from stored defaults")
            
        }
        
        
        self.getTimeAdjusts()
        
        
        updateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(300), target: self, selector: #selector(getTimeAdjusts), userInfo: nil, repeats: true) */
        
    }
    
   func adjustTime(events: [HLLEvent]) -> [HLLEvent] {
        
        if HLLDefaults.magdalene.adjustTimes == false {
            return events
        }
    
    return adjustTimeLegacy(events:events)
    
  /*  if EventTimeAdjuster.startTimeAdjusts.isEmpty == true, EventTimeAdjuster.endTimeAdjusts.isEmpty == true {
        
        
        
        
    } else {
        
        print("Using fetched timeadjusts")
        
    }
        
        var returnArray = [HLLEvent]()
        
        for event in events {
            
            if event.startDate.year() < 2019 {
                
                let today = event.startDate
                if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
                    let components = calendar.components([.weekday], from: today)
                    if let weekday = components.weekday {
                        
                        let dateFormatter  = DateFormatter()
                        dateFormatter.dateFormat = "h:mma"
                        let formattedStart = dateFormatter.string(from: event.startDate)
                        let formattedEnd = dateFormatter.string(from: event.endDate)
                        
                        if weekday == 2 {
                            
                            if formattedStart == "12:59pm" {
                                event.startDate = event.startDate - 600
                            }
                            
                        }
                        
                        if weekday == 3 {
                            
                            if formattedStart == "10:45am" {
                                event.startDate = event.startDate - 300
                            }
                            
                        }
                        
                        
                        if weekday == 4 || weekday == 5 || weekday == 6 {
                            
                            
                            if formattedStart == "12:50pm" {
                                event.startDate = event.startDate - 300
                            }
                            
                            if formattedStart == "11:20am" {
                                event.startDate = event.startDate + 300
                            }
                            
                            if formattedEnd == "11:20am" || formattedEnd == "12:10pm" {
                                event.endDate = event.endDate + 300
                            }
                        }
                    }
                }
                
                returnArray.append(event)
                
            } else {
                
                let today = event.startDate
                if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
                    let components = calendar.components([.weekday], from: today)
                    if let weekday = components.weekday {
                        
                       let weekdayString = String(weekday)
                        
                        let dateFormatter  = DateFormatter()
                        dateFormatter.dateFormat = "h:mma"
                        let formattedStart = dateFormatter.string(from: event.startDate)
                        let formattedEnd = dateFormatter.string(from: event.endDate)
                        
                        if let startDict = EventTimeAdjuster.startTimeAdjusts[weekdayString] {
                        
                        for key in startDict.keys {
                            
                            if key == formattedStart {
                                
                                event.startDate.addTimeInterval(TimeInterval(startDict[key]!))
                                
                            }
                            
                            
                        }
                            
                        }
                        
                        if let endDict = EventTimeAdjuster.endTimeAdjusts[weekdayString] {
                        
                        for key in endDict.keys {
                            
                            if key == formattedEnd {
                                
                                event.endDate.addTimeInterval(TimeInterval(endDict[key]!))
                                
                            }
                            
                            
                            
                        }
                        
                        }
                        
                    }
                }
                
                returnArray.append(event)
                
            }
            
        }
        
        return returnArray */
        
    }
    
    
    
   func adjustTimeLegacy(events: [HLLEvent]) -> [HLLEvent] {
    
  //  print("Fslling back to legacy time adjusts")
    
        if HLLDefaults.magdalene.adjustTimes == false {
            return events
        }
        
        var returnArray = [HLLEvent]()
        
        for eventItem in events {
        
            let event = eventItem
            
        if event.startDate.year() < 2019 {
            
        let today = event.startDate
        if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
            let components = calendar.components([.weekday], from: today)
            if let weekday = components.weekday {
                
                let dateFormatter  = DateFormatter()
                dateFormatter.dateFormat = "h:mma"
                let formattedStart = dateFormatter.string(from: event.startDate)
                let formattedEnd = dateFormatter.string(from: event.endDate)
                
                if weekday == 2 {
                    
                    if formattedStart == "12:59pm" {
                        event.startDate = event.startDate - 600
                    }
                    
                }
                
                if weekday == 3 {
                    
                    if formattedStart == "10:45am" {
                        event.startDate = event.startDate - 300
                    }
                    
                }
                
                
                if weekday == 4 || weekday == 5 || weekday == 6 {
                    
                    
                    if formattedStart == "12:50pm" {
                        event.startDate = event.startDate - 300
                    }
                    
                    if formattedStart == "11:20am" {
                        event.startDate = event.startDate + 300
                    }
                    
                    if formattedEnd == "11:20am" || formattedEnd == "12:10pm" {
                        event.endDate = event.endDate + 300
                    }
                }
            }
        }
            
            returnArray.append(event)
            
        } else {
            
            let today = event.startDate
            if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
                let components = calendar.components([.weekday], from: today)
                if let weekday = components.weekday {
                    
                    
                    
                    let dateFormatter  = DateFormatter()
                    dateFormatter.dateFormat = "h:mma"
                    let formattedStart = dateFormatter.string(from: event.startDate).lowercased()
                    //let formattedEnd = dateFormatter.string(from: event.endDate).lowercased()
                    
                    
                  if weekday == 3 {
                    
                    if formattedStart == "10:35am" {
                        event.startDate = event.startDate - 300 // Adjust period 2 start to 5 minutes earlier.
                    }
                        
                        
                    }
                    
                    
                    if weekday == 2 || weekday == 4 || weekday == 5 || weekday == 6 {
                        
                        if formattedStart == "10:10am" {
                            event.startDate = event.startDate - 300 // Adjust period 2 start to 5 minutes earlier.
                        }
                        
                        /* if formattedEnd == "12:40pm" {
                            event.endDate = event.endDate - 300 // Adjust period 3 end to 5 minutes earlier.
                        } */
                        
                        if formattedStart == "1:20pm" {
                            event.startDate = event.startDate - 300 // Adjust period 4 start to 5 minutes earlier.
                        }
                        
        
                        
                    }
                }
            }
            
            returnArray.append(event)
            
            }
            
        }

        return returnArray
    
    }
    
    
}

enum DayOfTheWeek: Int {
    
    case Sunday = 1
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    
    
}
