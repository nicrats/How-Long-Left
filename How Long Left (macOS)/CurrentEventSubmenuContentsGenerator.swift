//
//  CurrentEventSubmenuContentsGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 8/3/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class CurrentEventSubmenuContentsGenerator {
    
    static var shared = CurrentEventSubmenuContentsGenerator()
    
    func generateSubmenuContentsFor(event: HLLEvent) -> [[String]] {
        
        var arrayOne = [String]()
        
        arrayOne.append("On Now: \(event.title)")
        
        var arrayTwo = [String]()
        
       
        
        arrayTwo.append("Start: \(event.startDate.formattedTime())")
        arrayTwo.append("End: \(event.endDate.formattedTime())")
        
        
        if let period = event.magdalenePeriod {
            
            arrayTwo.append("Period: \(period)")
            
            
        }
        
        if let loc = event.location {
            
            if loc.contains(text: "Room:") {
                
                arrayTwo.append(loc)
                
            } else {
                
                arrayTwo.append("Location: \(loc)")
                
            }
            
        }
        
        var secondsLeft = event.duration
        // let minutesLeft = Int(secondsLeft/60+1)
        // let minText = MinutePluralizer(Minutes: minutesLeft)
        
        if let percentage = PercentageCalculator().calculatePercentageDone(event: event, ignoreDefaults: true) {
            
            
            arrayTwo.append("Completion: \(percentage)")
            
        }
        
        
        
        var secondsElapsed = Date().timeIntervalSince(event.startDate)
        // let minutesLeft = Int(secondsLeft/60+1)
        // let minText = MinutePluralizer(Minutes: minutesLeft)
        
        let formatter1 = DateComponentsFormatter()
        
        if secondsElapsed+1 > 86400 {
            secondsElapsed += 86400
            formatter1.allowedUnits = [.day]
            
        } else if secondsElapsed+1 > 3599 {
            
            formatter1.allowedUnits = [.hour, .minute]
            
        } else {
            
            formatter1.allowedUnits = [.minute]
            
        }
        
        formatter1.unitsStyle = .full
        let elapsed = formatter1.string(from: secondsElapsed+60)!
        
        arrayTwo.append("Elapsed: \(elapsed)")
        
        let formatter = DateComponentsFormatter()
        
        if secondsLeft+1 > 86400 {
            secondsLeft += 86400
            formatter.allowedUnits = [.day]
            
        } else if secondsLeft+1 > 3599 {
            
            formatter.allowedUnits = [.hour, .minute]
            
        } else {
            
            formatter.allowedUnits = [.minute]
            
        }
        
        formatter.unitsStyle = .full
        let countdownText = formatter.string(from: secondsLeft+60)!
        
        
        arrayTwo.append("Duration: \(countdownText)")
        
        return [arrayOne, arrayTwo]
        
        
    }
    
    
}
