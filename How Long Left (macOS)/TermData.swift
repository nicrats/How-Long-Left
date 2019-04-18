//
//  TermData.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 22/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

struct TermData {
    
    var menuString: String
    var topRow = [String]()
    var submenuItems = [String]()
    var onNow = false
    
    init(nextHolidays: HLLEvent) {
        
        var closeText: String?
        
        let currentEvent = nextHolidays
        let secondsLeft = currentEvent.startDate.midnight().timeIntervalSinceNow+1+86400
        
        let formatter = DateComponentsFormatter()
        if HLLDefaults.statusItem.useFullUnits == true {
            formatter.unitsStyle = .full
        } else {
            formatter.unitsStyle = .short
        }
        
        if secondsLeft < 172799 {
            
            closeText = "Tomorrow"
            
        }
        
        if secondsLeft > 86400 {
            
           // secondsLeft += 86400
            formatter.allowedUnits = [.day, .weekOfMonth]
            formatter.unitsStyle = .full
            
        } else {
            
            
            closeText = "Today"
            
        }
        
        if secondsLeft < 0 {
            
            onNow = true
            
        }
        
        
        
        var countdownText = "in \(formatter.string(from: secondsLeft+60)!)"
        
        if let close = closeText {
            
            countdownText = "Starts \(close)"
            
        }
        
        
        
        var topRowItem: String
        
        if countdownText.last == "." {
            countdownText = String(countdownText.dropLast())
        }
        
        if let term = nextHolidays.holidaysTerm {
            
            topRowItem = "Term \(term) School Holidays"
            
            if let closeT = closeText {
                
                menuString = "\(closeT) is the last day of Term \(term)."
                
            } else {
                
                menuString = "Term \(term) ends \(countdownText)."
                
                
            }
            
            
            
        } else {
            
            if let closeT = closeText {
                
                menuString = "School Holidays start \(closeT.lowercased())."
            } else {
                menuString = "Holidays start \(countdownText)."
                
            }
            
            topRowItem = "School Holidays"
            menuString = "Holidays start \(countdownText)."
            
        }
        
        let countdownTopRow = "\(countdownText)"
        
        
        
        topRow.append(topRowItem)
        topRow.append(countdownTopRow.capitalized)
        
       
        submenuItems.append("Start: \(nextHolidays.startDate.formattedDate())")
        submenuItems.append("End: \(nextHolidays.endDate.formattedDate())")
        
        let seconds = nextHolidays.endDate.timeIntervalSince(nextHolidays.startDate)-1
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        let lengthText = formatter.string(from: seconds+60)!
        
        submenuItems.append("Duration: \(lengthText)")
        
        
    }
    
    
    
}
