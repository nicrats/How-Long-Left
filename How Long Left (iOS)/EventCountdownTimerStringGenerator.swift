//
//  EventCountdownTimerStringGenerator.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 21/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventCountdownTimerStringGenerator {

    
    func generateStringFor(event: HLLEvent, start: Bool = false, advanceBySeconds: Int = 0, isForWatch: Bool = false) -> String? {
        
        var returnString: String?
        
        var secondsLeft: TimeInterval
        
        
        
        if start == true {
            
           secondsLeft = event.startDate.timeIntervalSince(Date()).rounded(.down)
            
        } else {
            
            secondsLeft = event.endDate.timeIntervalSince(Date()).rounded(.down)
            
        }
        
        secondsLeft -= Double(advanceBySeconds)
        
        if secondsLeft < 0 {
            
            return "0:00"
            
        }
        
        if secondsLeft > -2 {
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            
            if secondsLeft+1 > 86400 {
                
                if isForWatch == false {
                
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                    
                } else {
                   
                    formatter.allowedUnits = [.day]
                    formatter.unitsStyle = .full
                    
                }
                
            } else if secondsLeft+1 > 3599 {
                
                formatter.allowedUnits = [.hour, .minute, .second]
                
            } else {
                
                formatter.allowedUnits = [.minute, .second]
            }
            
            formatter.zeroFormattingBehavior = [ .dropLeading ]
            let formattedDuration = formatter.string(from: secondsLeft+1)
            
            returnString = "\(formattedDuration!)"
            
            
        }
        
        return returnString
        
    }
    
    
}

protocol CountdownUI {
    
    func setCountdownString(to: String)
    
    
}
