//
//  MagdaleneBreaks.swift
//  How Long Left
//
//  Created by Ryan Kontos on 1/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class MagdaleneBreaks {
    
    static let shared = MagdaleneBreaks()
    
    func getBreaks(events: [HLLEvent]) -> [HLLEvent] {
        
        // Check if the day's current events line up with a Magdalene timetable, if so return EKEvents of Lunch and Recess
        
        var returnArray = [HLLEvent]()
        
        if HLLDefaults.magdalene.showBreaks == false {
            return returnArray
        }
        
        var alreadyContainedRecess = false
        var alreadyContainedLunch = false
        
        if events.isEmpty == false {
            
            let today = events.first!.startDate.midnight()
            
            var startTimesDictionary = [String : HLLEvent]()
            var endTimesDictionary = [String : HLLEvent]()
            
            for event in events {
                
                startTimesDictionary[event.startDate.formattedTime()] = event
                endTimesDictionary[event.endDate.formattedTime()] = event
                
                
              if event.title == "Recess" {
                    alreadyContainedRecess = true
                }
                
                if event.title == "Lunch" {
                    alreadyContainedLunch = true
                }
                
            }
            
            if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
                let components = calendar.components([.weekday], from: today)
                if let weekday = components.weekday {
                    
                    let calendar = Calendar.current
                    let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
                    
                    var recessStart: Date?
                    var recessEnd: Date?
                    var lunchStart: Date?
                    var lunchEnd: Date?
                    
                    if events[0].startDate.year() > 2018 {
                        
                        switch weekday {
                            
                        case 3:
                            
                            // 2019+ break times for Tuesday
                            
                            var rStart = todayComponents
                            rStart.hour = 10
                            rStart.minute = 15
                            rStart.second = 00
                            recessStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rStart)!
                            
                            var rEnd = todayComponents
                            rEnd.hour = 10
                            rEnd.minute = 35
                            rEnd.second = 00
                            recessEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rEnd)!
                            
                            var lStart = todayComponents
                            lStart.hour = 12
                            lStart.minute = 25
                            lStart.second = 00
                            lunchStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lStart)!
                            
                            var lEnd = todayComponents
                            lEnd.hour = 12
                            lEnd.minute = 55
                            lEnd.second = 00
                            lunchEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lEnd)!
                            
                            
                        case 2,4,5,6:
                            
                            // 2019+ break times for Monday, Wednesday, Thursday, Friday
                            
                            var rStart = todayComponents
                            rStart.hour = 9
                            rStart.minute = 50
                            rStart.second = 00
                            recessStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rStart)!
                            
                            var rEnd = todayComponents
                            rEnd.hour = 10
                            rEnd.minute = 05
                            rEnd.second = 00
                            recessEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rEnd)!
                            
                            var lStart = todayComponents
                            lStart.hour = 12
                            lStart.minute = 40
                            lStart.second = 00
                            lunchStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lStart)!
                            
                            var lEnd = todayComponents
                            lEnd.hour = 13
                            lEnd.minute = 15
                            lEnd.second = 00
                            lunchEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lEnd)!
                            
                        default:
                            
                            recessStart = nil
                            recessEnd = nil
                            
                            lunchStart = nil
                            lunchEnd = nil
                            
                        }
                        
                    } else {
                    
                    switch weekday {
                        
                    case 2:
                        
                        // 2018 break times of Monday
                        
                        var rStart = todayComponents
                        rStart.hour = 10
                        rStart.minute = 21
                        rStart.second = 00
                        recessStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rStart)!
                        
                        var rEnd = todayComponents
                        rEnd.hour = 10
                        rEnd.minute = 43
                        rEnd.second = 00
                        recessEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rEnd)!
                        
                        var lStart = todayComponents
                        lStart.hour = 12
                        lStart.minute = 19
                        lStart.second = 00
                        lunchStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lStart)!
                        
                        var lEnd = todayComponents
                        lEnd.hour = 12
                        lEnd.minute = 49
                        lEnd.second = 00
                        lunchEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lEnd)!
                        
                        
                    case 3:
                        
                        // 2018 break times for Tuesday
                        
                        var rStart = todayComponents
                        rStart.hour = 10
                        rStart.minute = 25
                        rStart.second = 00
                        recessStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rStart)!
                        
                        var rEnd = todayComponents
                        rEnd.hour = 10
                        rEnd.minute = 40
                        rEnd.second = 00
                        recessEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rEnd)!
                        
                        var lStart = todayComponents
                        lStart.hour = 12
                        lStart.minute = 25
                        lStart.second = 00
                        lunchStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lStart)!
                        
                        var lEnd = todayComponents
                        lEnd.hour = 13
                        lEnd.minute = 00
                        lEnd.second = 00
                        lunchEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lEnd)!
                        
                        
                    case 4,5,6:
                        
                        // 2018 break times for Wednesday, Thursday, Friday
                        
                        var rStart = todayComponents
                        rStart.hour = 10
                        rStart.minute = 10
                        rStart.second = 00
                        recessStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rStart)!
                        
                        var rEnd = todayComponents
                        rEnd.hour = 10
                        rEnd.minute = 30
                        rEnd.second = 00
                        recessEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: rEnd)!
                        
                        var lStart = todayComponents
                        lStart.hour = 12
                        lStart.minute = 15
                        lStart.second = 00
                        lunchStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lStart)!
                        
                        var lEnd = todayComponents
                        lEnd.hour = 12
                        lEnd.minute = 45
                        lEnd.second = 00
                        lunchEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.date(from: lEnd)!
                        
                    default:
                        
                        recessStart = nil
                        recessEnd = nil
                        
                        lunchStart = nil
                        lunchEnd = nil
                        
                    }
                    
                }
                    
                    if let uRecessStart = recessStart, let uRecessEnd = recessEnd, alreadyContainedRecess == false {
                        
                        let formattedRecessStart = uRecessStart.formattedTime()
                        let formattedRecessEnd = uRecessEnd.formattedTime()
                        let difFromEnd = Int(CFDateGetTimeIntervalSinceDate(uRecessEnd as CFDate, today as CFDate?))
                        
                        
                        if endTimesDictionary.keys.contains(formattedRecessStart), startTimesDictionary.keys.contains(formattedRecessEnd), difFromEnd > 0 {
                            
                            var event = HLLEvent(title: "Recess", start: uRecessStart, end: uRecessEnd, location: nil)
                            event.isMagdaleneBreak = true
                            
                            if let startEvent = endTimesDictionary[formattedRecessStart], let endEvent = startTimesDictionary[formattedRecessEnd] {
                                
                                if startEvent.calendar?.calendarIdentifier == endEvent.calendar?.calendarIdentifier {
                                    
                                    event.calendar = startEvent.calendar
                                    
                                }
                                
                            }
                            
                            
                            returnArray.append(event)
                            
                        }
                    }
                    
                    if let uLunchStart = lunchStart, let uLunchEnd = lunchEnd, alreadyContainedLunch == false {
                        
                        let formattedLunchStart = uLunchStart.formattedTime()
                        let formattedLunchEnd = uLunchEnd.formattedTime()
                        let difFromEnd = Int(CFDateGetTimeIntervalSinceDate(uLunchEnd as CFDate, today as CFDate?))
                        
                        
                        if endTimesDictionary.keys.contains(formattedLunchStart), startTimesDictionary.keys.contains(formattedLunchEnd), difFromEnd > 0 {
                            
                            var event = HLLEvent(title: "Lunch", start: uLunchStart, end: uLunchEnd, location: nil)
                            event.isMagdaleneBreak = true
                            
                            if let startEvent = endTimesDictionary[formattedLunchStart], let endEvent = startTimesDictionary[formattedLunchEnd] {
                                
                                if startEvent.calendar?.calendarIdentifier == endEvent.calendar?.calendarIdentifier {
                                    
                                    event.calendar = startEvent.calendar
                                    
                                }
                                
                            }
                            
                            returnArray.append(event)
                            
                        }
                    }
                    
                }
            }
            
            /* var comp: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: Date().addingTimeInterval(EventData.sharedData.lookAheadTime))
             comp.timeZone = TimeZone.current
             let startDate = NSCalendar.current.date(from: comp)!
             let endD = startDate.addingTimeInterval(54000)
             
             let EKRecessT = EKEvent()
             EKRecessT.title = "Recess"
             EKRecessT.startDate = startDate
             EKRecessT.endDate = endD
             returnArray.append(EKRecessT) */
            
        }
        
        return returnArray
        
    }
    
    
}
