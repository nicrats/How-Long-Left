//
//  SchoolHolidaysStringGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 12/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolHolidaysStringGenerator {
    
    func generateStatusItemHolidaysCountdownTo(nextHolidays: HLLEvent?) -> String? {
        
        if let unextHolidays = nextHolidays {
            
            let startsIn = unextHolidays.startDate.timeIntervalSinceNow
            
            if startsIn < 604800, startsIn > 0 {
                
                let startsInDays = startsIn/60/60/24
                
                return "\(unextHolidays.title) starts in \(startsInDays)."
                
            } else {
                
                return nil
                
            }
            
        } else {
            
            return nil
            
        }
        
        
    }
    
    
}
