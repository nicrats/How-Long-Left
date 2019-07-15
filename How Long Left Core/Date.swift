//
//  Date.swift
//  How Long Left
//
//  Created by Ryan Kontos on 12/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

extension Date {
    
    func userFriendlyRelativeString() -> String {
        
        let daysUntilDate = self.daysUntil()
        var dayText: String
        
        switch daysUntilDate {
        case 0:
            dayText = "Today"
        case 1:
            dayText = "Tomorrow"
        default:
            let dateFormatter  = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            dayText = dateFormatter.string(from: self)
        }
        
        return dayText
        
    }
    
    func daysUntil() -> Int {
        
        return Int(self.timeIntervalSince(Date().midnight()))/60/60/24
        
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
        
        
        let dateFormatter  = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        
        return dateFormatter.string(from: self)
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
    
    func midnight() -> Date {
        
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        return cal.startOfDay(for: self)
        
    }
    
}
