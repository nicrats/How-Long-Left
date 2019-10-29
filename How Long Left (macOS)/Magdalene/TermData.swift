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
    
    init(nextHolidays: HLLEvent, previousHolidays: HLLEvent?) {
        
        var closeText: String?
        
        let currentEvent = nextHolidays
        let secondsLeft = currentEvent.startDate.startOfDay().timeIntervalSinceNow+1+86400
        
        var isNumber = false
        
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
            isNumber = true
            
            
        } else {
            
            
            closeText = "Today"
            
        }
        
        if secondsLeft < 0 {
            
            onNow = true
            
        }
        
        
        
        
        
        var countdownText = "\(formatter.string(from: secondsLeft+60)!)"
        
        if isNumber == true {
            
            countdownText = "in \(countdownText)"
            
        }
        
        if let close = closeText {
            
            countdownText = "Ends \(close)"
            
        }
        
        
        
        var topRowItem: String
        
        if countdownText.last == "." {
            countdownText = String(countdownText.dropLast())
        }
        
        var holidaysText = "School Holidays:"
        
        if let term = nextHolidays.holidaysTerm {
            
            topRowItem = "Term \(term)"
            
            if let prev = previousHolidays {
                
                let currentTermStart = prev.endDate
                let currentTermEnd = nextHolidays.startDate
                
                let secondsElapsed = Date().timeIntervalSince(currentTermStart)
                let totalSeconds = currentTermEnd.timeIntervalSince(currentTermStart)
                let percentOfEventComplete = Int(100*secondsElapsed/totalSeconds)
                
                topRowItem = "\(topRowItem) (\(percentOfEventComplete)% Done)"
                
                
            }
            
            if let closeT = closeText {
                
                menuString = "\(closeT) is the last day of Term \(term)."
                
            } else {
                
                menuString = "Term \(term) ends \(countdownText)."
                
                
            }
            
            holidaysText = "Term \(term) School Holidays:"
            
        } else {
            
            if let closeT = closeText {
                
                menuString = "School Holidays start \(closeT.lowercased())."
            } else {
                menuString = "Holidays start \(countdownText)."
                
            }
            
            topRowItem = "School Holidays"
            menuString = "Holidays start \(countdownText)."
            
        }
        
        if let prev = previousHolidays {
            
            let currentTermStart = prev.endDate
            let currentTermEnd = nextHolidays.startDate
            
            let secondsElapsed = Date().timeIntervalSince(currentTermStart)
            let totalSeconds = currentTermEnd.timeIntervalSince(currentTermStart)
            let percentOfEventComplete = Int(100*secondsElapsed/totalSeconds)
            
            menuString = "\(menuString) (\(percentOfEventComplete)%)"
            
            
        }
        
        var countdownTopRow: String
        
        if countdownText.lowercased().contains(text: "ends") {
            
            countdownTopRow = "\(countdownText)"
            
        } else {
            
            countdownTopRow = "Ends \(countdownText)"
            
        }
        
        
        
        
        
        
        topRow.append(topRowItem)
        topRow.append(countdownTopRow)
        
        
        submenuItems.append(holidaysText)
       
        submenuItems.append("Start: \(nextHolidays.startDate.formattedDate())")
        submenuItems.append("End: \(nextHolidays.endDate.formattedDate())")
        
        let seconds = nextHolidays.endDate.timeIntervalSince(nextHolidays.startDate)-1
        formatter.allowedUnits = [.day, .weekOfMonth]
        formatter.unitsStyle = .full
        let lengthText = formatter.string(from: seconds+60)!
        
        submenuItems.append("Duration: \(lengthText)")
        
        
    }
    
    
    
}
