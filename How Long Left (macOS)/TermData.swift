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
    
    init(nextHolidays: HLLEvent) {
        
        
       let currentEvent = nextHolidays
        let secondsLeft = currentEvent.startDate.timeIntervalSinceNow+1
        
        let formatter = DateComponentsFormatter()
        if HLLDefaults.statusItem.useFullUnits == true {
            formatter.unitsStyle = .full
        } else {
            formatter.unitsStyle = .short
        }
        
        
        if secondsLeft > 86400 {
           // secondsLeft += 86400
            formatter.allowedUnits = [.day, .weekOfMonth]
            formatter.unitsStyle = .full
            
        } else if secondsLeft > 3599 {
            
            formatter.allowedUnits = [.hour, .minute]
            
        } else {
            
            formatter.allowedUnits = [.minute]
            
        }
        
       
        
        
        var countdownText = formatter.string(from: secondsLeft+60)!
        
        if countdownText.last == "." {
            countdownText = String(countdownText.dropLast())
        }
        
        if let term = nextHolidays.holidaysTerm {
            
            menuString = "Term \(term) ends in \(countdownText)."
            
        } else {
            
          menuString = "Holidays start in \(countdownText)."
            
        }
        
        
        
        
    }
    
    
    
}
