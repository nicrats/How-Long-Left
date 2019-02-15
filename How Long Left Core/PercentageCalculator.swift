//
//  PercentageCalculator.swift
//  How Long Left
//
//  Created by Ryan Kontos on 14/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class PercentageCalculator {
    
    func calculatePercentageDone(event: HLLEvent) -> String? {
        
        
        if HLLDefaults.magdalene.showHolidaysPercent == false {
            
            if event.isHolidays == true {
                
                return nil
            }
            
        }
        
        let secondsElapsed = Date().timeIntervalSince(event.startDate)
        let totalSeconds = event.endDate.timeIntervalSince(event.startDate)
        let percentOfEventComplete = Int(100*secondsElapsed/totalSeconds)
        
        return "\(percentOfEventComplete)%"
        
    }
    
    
    
}
