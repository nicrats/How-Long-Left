//
//  PercentageCalculator.swift
//  How Long Left
//
//  Created by Ryan Kontos on 14/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class PercentageCalculator {
    
    func calculatePercentageDone(for event: HLLEvent, at date: Date = Date()) -> String? {
        
        if event.completionStatus == .Upcoming {
            
            return nil
            
        }
        
        let secondsElapsed = date.timeIntervalSince(event.startDate)
        let totalSeconds = event.endDate.timeIntervalSince(event.startDate)
        var percentOfEventComplete = Int(100*secondsElapsed/totalSeconds)
        
        if percentOfEventComplete > 100 {
            percentOfEventComplete = 100
        }
        
        return "\(percentOfEventComplete)%"
        
    }
    
    func calculateDoubleDone(of event: HLLEvent) -> Float {
        
        let secondsElapsed = Date().timeIntervalSince(event.startDate)
        let totalSeconds = event.endDate.timeIntervalSince(event.startDate)
        let double = secondsElapsed/totalSeconds
        return Float(double)
        
    }
    
    
    
}
