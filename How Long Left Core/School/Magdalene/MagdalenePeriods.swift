//
//  MagdalenePeriods.swift
//  How Long Left
//
//  Created by Ryan Kontos on 27/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class MagdalenePeriods {
    
    static let shared = MagdalenePeriods()
    
    func magdalenePeriodsFor(events: [HLLEvent]) -> [HLLEvent] {
        
        // Take a Magdalene event and return its period number if avaliable.
        
        var returnArray = [HLLEvent]()
        
        for eventItem in events {
        
            var event = eventItem
            
        var period: String?
        
        let eventStartTimeFormatted = event.startDate.formattedTime().lowercased()
        
        if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
            let components = calendar.components([.weekday], from: event.startDate)
            if let weekday = components.weekday {
                
                if event.startDate.year() > 2018 {
                    
                    switch weekday {
                        
                    case 2,4,5,6:
                        
                        // 2019+ Monday, Wednesday, Thurday, Friday Periods
                        
                        switch eventStartTimeFormatted {
                        case "8:15am":
                            period = "1"
                        case "9:30am":
                            period = "H"
                        case "9:50am":
                            period = "R"
                        case "10:05am":
                            period = "2"
                        case "10:10am":
                            period = "2"
                        case "11:25am":
                            period = "3"
                        case "12:40pm":
                            period = "L"
                        case "1:15pm":
                            period = "4"
                        case "1:20pm":
                            period = "4"
                        default:
                            period = nil
                            
                        }
                        
                    case 3:
                        
                        // 2019+ Tuesday Periods
                        
                        switch eventStartTimeFormatted {
                        case "8:15am":
                            period = "1"
                        case "9:15am":
                            period = "2"
                        case "10:15am":
                            period = "R"
                        case "10:30am":
                            period = "H"
                        case "10:35am":
                            period = "H"
                        case "11:25am":
                            period = "3"
                        case "12:25pm":
                            period = "L"
                        case "12:55pm":
                            period = "S"
                        default:
                            period = nil
                        }
                        
                    default:
                        period = nil
                    }
                    
                    
                } else {
                
                switch weekday {
                    
                case 2:
                    
                    // 2018 Monday Periods
                    
                    switch eventStartTimeFormatted {
                    case "8:15am":
                        period = "PC"
                    case "8:45am":
                        period = "1"
                    case "9:33am":
                        period = "2"
                    case "10:21am":
                        period = "R"
                    case "10:43am":
                        period = "3"
                    case "11:31am":
                        period = "4"
                    case "12:19pm":
                        period = "L"
                    case "12:49pm":
                        period = "5"
                    case "12:59pm":
                        period = "5"
                    case "1:00pm":
                        period = "5"
                    case "1:47pm":
                        period = "6"
                    case "1:48pm":
                        period = "6"
                    default:
                        period = nil
                    }
                    
                case 3:
                    
                    // 2018 Tuesday Periods
                    
                    switch eventStartTimeFormatted {
                    case "8:15am":
                        period = "PC"
                    case "8:45am":
                        period = "1"
                    case "9:35am":
                        period = "2"
                    case "10:25am":
                        period = "R"
                    case "10:45am":
                        period = "3"
                    case "10:40am":
                        period = "3"
                    case "11:35am":
                        period = "4"
                    case "12:25pm":
                        period = "L"
                    default:
                        period = nil
                    }
                    
                case 4,5,6:
                    
                    // 2018 Wednesday, Thursday, Friday Periods
                    
                    switch eventStartTimeFormatted {
                    case "8:15am":
                        period = "PC"
                    case "8:30am":
                        period = "1"
                    case "9:20am":
                        period = "2"
                    case "10:10am":
                        period = "R"
                    case "10:30am":
                        period = "3"
                    case "11:20am":
                        period = "4"
                    case "11:25am":
                        period = "4"
                    case "12:15pm":
                        period = "L"
                    case "12:40pm":
                        period = "5"
                    case "12:50pm":
                        period = "5"
                    case "12:45pm":
                        period = "5"
                    case "1:45pm":
                        period = "6"
                    default:
                        period = nil
                        
                    }
                    
                default:
                    period = nil
                }
                
                }
            }
        }
            
            event.magdalenePeriod = period
            returnArray.append(event)
            
        }
        
        
        return returnArray
        
    }
    
    
}
