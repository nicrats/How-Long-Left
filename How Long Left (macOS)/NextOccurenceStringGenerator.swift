//
//  NextOccurenceStringGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 30/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class NextOccurenceStringGenerator {

func generateNextOccurenceItems(events: [HLLEvent]) -> [(String, [String])] {
    
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    var returnItems = [(String, [String])]()
    
    for event in events {
        
        let cal: Calendar = Calendar(identifier: .gregorian)
        let midnightToday: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let nextOccurDay: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: event.startDate)!
        let NXOsec = nextOccurDay.timeIntervalSince(midnightToday)
        let NXOdays = NXOsec/60/60/24
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let formattedEnd = dateFormatter.string(from: event.startDate)
        
        var dayText = formattedEnd
        
        switch NXOdays {
        case 0:
            dayText = "Today"
        case 1:
            dayText = "Tomorrow"
        default:
            dayText = formattedEnd
        }
        
        var eventTimeInfo = event.startDate.formattedTime()
        let infoMenuTimeInfo = "Time: \(eventTimeInfo)"
        var infoMenuPeriodInfo: String?
        
        if let period = event.magdalenePeriod {
            
            eventTimeInfo = "Period \(period)"
            infoMenuPeriodInfo = "Period: \(period)"
            
        }
        
        let rowTitle = "Next \(event.shortTitle): \(dayText), \(eventTimeInfo)"
        
        let components = calendar?.components([.weekOfYear], from: Date())
        let currentWeekOfYear = components!.weekOfYear!
        let components2 = calendar?.components([.weekOfYear], from: event.startDate)
        let eventWeekOfYear = components2!.weekOfYear!
        
        let weekDif = eventWeekOfYear-currentWeekOfYear
        
        var infoArray = [String]()
        
        var titleInfo = "\(event.title) - \(dayText)"
        
        if weekDif != 0 {
            
            titleInfo += " (Next week)"
            
        }
        
        infoArray.append(titleInfo)
        
        if NXOdays != 0 {
        var daysFromNowText = "day"
        if NXOdays != 1 {
            daysFromNowText += "s"
        }
        
        infoArray.append("\(Int(NXOdays)) \(daysFromNowText) from now.")
        } else {
            
            let secondsLeft = event.startDate.timeIntervalSinceNow
            
            let formatter = DateComponentsFormatter()
            
             if secondsLeft > 3599 {
                
                formatter.allowedUnits = [.hour, .minute]
                
            } else {
                
                formatter.allowedUnits = [.minute]
                
            }
            
            formatter.unitsStyle = .full
            let countdownText = formatter.string(from: secondsLeft+60)!
            infoArray.append("Starting in \(countdownText).")
            
        }
        
    
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yy"
        let formattedDate = dateFormatterPrint.string(from: event.startDate)
        
        infoArray.append("Date: \(formattedDate)")
        
        if let location = event.location, HLLDefaults.general.showLocation == true {
            
            if location.contains(text: "Room:") == false {
                
                infoArray.append("Location: \(location)")
                
            } else {
                
                infoArray.append(location)
                
            }
            
        }
        
        if let periodInfo = infoMenuPeriodInfo {
            
            infoArray.append(periodInfo)
            
        }
        
        infoArray.append(infoMenuTimeInfo)
        
        
        if let ek = event.EKEvent, let notes = ek.notes {
            
            let lines = notes.split { $0.isNewline }
            
            for line in lines {
                
                if line.contains("Teacher") {
                    
                   infoArray.append(String(line))
                    
                }
                
            }
            
        }

        
        returnItems.append((rowTitle, infoArray))
        
        
    }
    
    return returnItems
    
}

}
