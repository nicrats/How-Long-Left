//
//  Date.swift
//  How Long Left
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

extension Date {
    
    func idString() -> String {
        
        return "\(self.formattedDate()), \(self.formattedTime())"
        
    }
    
    func userFriendlyRelativeString() -> String {
        
        let daysUntilDate = self.daysUntil()
        var dayText: String
        
        let dateFormatter  = DateFormatter()
        if self.year() == Date().year() {
            
            dateFormatter.dateFormat = "d MMM"
            
        } else {
            
            dateFormatter.dateFormat = "d MMM YYYY"
            
        }
        
        let dateString = dateFormatter.string(from: self)
        
        if daysUntilDate < -1 {
            
           return dateString
            
        }
        
        switch daysUntilDate {
        case -1:
            dayText = "Yesterday"
        case 0:
            dayText = "Today"
        case 1:
            dayText = "Tomorrow"
        default:
            
            if daysUntilDate < 7 {
            
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            dayText = dateFormatter.string(from: self)
                
            } else {
                
                return dateString
                
            }
        }
        
        return dayText
        
    }
    
    var hasOccured: Bool {
        
        get {
            
            if self.timeIntervalSinceNow > 0 {
                return false
            } else {
                return true
            }
            
        }
        
    }
    
    func daysUntil() -> Int {
        
        return Int(self.startOfDay().timeIntervalSince(Date().startOfDay()))/60/60/24
        
    }
    
    func getDayOfWeekName(returnTodayIfToday: Bool) -> String {
        
        var returnText: String
        
        let dateFormatter  = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        returnText = dateFormatter.string(from: self)
        
        if self.daysUntil() == 0, returnTodayIfToday {
            
            returnText = "Today"
            
        }
        
        if self.daysUntil() == 1, returnTodayIfToday {
            
            returnText = "Tomorrow"
            
        }
        
        return returnText
        
    }
    
    func weekOfYear() -> Int {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        return calendar.components([.weekOfYear], from: self).weekOfYear!
        
        
    }
    
    func formattedTime() -> String {
        
        
        let dateFormatter  = DateFormatter()
        
        if HLLDefaults.general.use24HourTime == true {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "h:mma"
        }
        
        return dateFormatter.string(from: self)
    }
    
    func formattedTimeTwelve() -> String {
        
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_AU")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        let r = formatter.string(from: self)
             
        return r
    }
    
    func formattedDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
        
    }
    
    func year() -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        return Int(dateFormatter.string(from: self))!
        
    }
    
    func startOfDay() -> Date {
        
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        return cal.startOfDay(for: self)
        
    }
    
    func endOfDay() -> Date {
        
        return self.startOfDay().addingTimeInterval(86400)
        
    }
    
}
