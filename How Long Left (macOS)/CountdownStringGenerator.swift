//
//  CountdownStringGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 30/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import AppKit

class CountdownStringGenerator {
    
    func generateStatusItemString(event: HLLEvent?) -> String? {
        
        if let countdownEvent = event {
            
            var returnString: String
            
            let currentEvent = countdownEvent
            var secondsLeft = currentEvent.endDate.timeIntervalSinceNow
            
            let formatter = DateComponentsFormatter()
            
            if secondsLeft+1 > 86400 {
                
                secondsLeft += 86400
                formatter.allowedUnits = [.day]
                
            } else if secondsLeft+1 > 3599 {
                
                formatter.allowedUnits = [.hour, .minute]
                
            } else {
                
                formatter.allowedUnits = [.minute]
                
            }
            
            if HLLDefaults.statusItem.useFullUnits == true {
                formatter.unitsStyle = .full
            } else {
                formatter.unitsStyle = .short
            }
            
            
            var countdownText = formatter.string(from: secondsLeft+60)!
            
            if countdownText.last == "." {
                countdownText = String(countdownText.dropLast())
            }
            
           // let minutesLeft = Int(secondsLeft/60+1)
           // let minText = MinutePluralizer(Minutes: minutesLeft)
            
            returnString = "\(countdownText)"
            
            if HLLDefaults.statusItem.showTitle == true {
                returnString = "\(countdownEvent.shortTitle): \(returnString)"
            }
            
            
            
            if HLLDefaults.statusItem.showLeftText == true {
                returnString = "\(returnString) left"
            }
            
            if let percent = generatePercentOfEventComplete(event: currentEvent), HLLDefaults.statusItem.showPercentage == true {
                
                returnString += " (\(percent))"
                
            }
            
            return returnString
            
        } else {
            
            return nil
        }
        
        
        
    }
    
    func generateCurrentEventStrings(currentEvents: [HLLEvent], nextEvents: [HLLEvent]) -> [(String, String?, HLLEvent?)] {
        
        var returnArray = [(String, String?, HLLEvent?)]()
        
        if currentEvents.isEmpty == false {
            
            for event in currentEvents {
                
                var percentText: String?
                
                
                let returnText = generateRegularCountdownText(event: event)
                
                if let percent = generatePercentOfEventComplete(event: event), HLLDefaults.general.showPercentage {
                    
                    percentText = "(\(percent) Done)"
                }
                
                returnArray.append((returnText, percentText, event))
                
            }
            
            
        } else {
           
            returnArray.append(("No events are on right now.", nil, nil))
            
        }
        
        return returnArray
        
    }
    
    func generateCountdownNotificationStrings(event: HLLEvent) -> (String, String?) {
 
        return (generateRegularCountdownText(event: event), generatePercentOfEventComplete(event: event))
        
    }
 
    
   private func generateRegularCountdownText(event: HLLEvent) -> String {
        
        var secondsLeft = event.endDate.timeIntervalSinceNow-1
       // let minutesLeft = Int(secondsLeft/60+1)
       // let minText = MinutePluralizer(Minutes: minutesLeft)
    
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
    
    
        return "\(event.title) ends in \(countdownText)."
    
    }
    
    func generatePercentOfEventComplete(event: HLLEvent) -> String? {
        
        
        if HLLDefaults.magdalene.showHolidaysPercent == false {
            
            if event.isHolidays == true {
                
                return nil
            }
            
        }
        
        
        let secondsElapsed = Int(Date().timeIntervalSince(event.startDate))+1
        let totalSeconds = Int(event.endDate.timeIntervalSince(event.startDate))
        let percentOfEventComplete = 100*secondsElapsed/totalSeconds
        return "\(percentOfEventComplete)%"
        
    }
    
}
