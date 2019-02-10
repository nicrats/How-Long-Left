//
//  EventCountdownTimerStringGenerator.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 21/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventCountdownTimerStringGenerator {
    
    func generateStringFor(event: HLLEvent) -> String? {
        
        var returnString: String?
        
        let secondsLeft = event.endDate.timeIntervalSince(Date()).rounded(.down)
        
        if secondsLeft > -2 {
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            
            if secondsLeft+1 > 86400 {
                
                formatter.allowedUnits = [.day]
                
            } else if secondsLeft+1 > 3599 {
                
                formatter.allowedUnits = [.hour, .minute, .second]
                
            } else {
                
                formatter.allowedUnits = [.minute, .second]
            }
            
            formatter.zeroFormattingBehavior = [ .pad ]
            let formattedDuration = formatter.string(from: secondsLeft+1)
            
            returnString = "\(formattedDuration!)"
            
            
        }
        
        return returnString
        
    }
    
    
}
