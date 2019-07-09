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
    
    let pecentageCalc = PercentageCalculator()
    
    let nextOccurFind = EventNextOccurenceFinder()
    
    func generateStatusItemString(event: HLLEvent, justTimer: Bool = false) -> String? {
            
            var returnString = genTimerString(date: event.endDate)
            
            if justTimer == false {
            
            if HLLDefaults.statusItem.showTitle == true {
                returnString = "\(event.shortTitle): \(returnString)"
            }
            
            if HLLDefaults.statusItem.showLeftText == true {
                returnString = "\(returnString) left"
            }
                
            if HLLDefaults.statusItem.showEndTime == true, event.endDate.midnight() == Date().midnight() {
                
            returnString = "\(returnString) (\(event.endDate.formattedTime()))"
                    
            }
            
            if HLLDefaults.statusItem.showPercentage == true, let percent = pecentageCalc.calculatePercentageDone(event: event, ignoreDefaults: false) {
                returnString = "\(returnString) (\(percent))"
            }
                
            }
        
            
        
        
        return returnString
        
    }
    
    func generateStatusItemMinuteModeString(event: HLLEvent?) -> String? {
        
        if let countdownEvent = event {
            
            var returnString: String
            
            let currentEvent = countdownEvent
            let secondsLeft = currentEvent.endDate.timeIntervalSinceNow
            
            let formatter = DateComponentsFormatter()
            
           
            
            if secondsLeft > 86399 {
                
                formatter.allowedUnits = [.day, .weekOfMonth]
                
            } else if secondsLeft > 3600 {
                
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
            
            returnString = "\(countdownText)"
            
            if HLLDefaults.statusItem.showTitle == true {
                returnString = "\(countdownEvent.shortTitle): \(returnString)"
            }
            
            
            
            if HLLDefaults.statusItem.showLeftText == true {
                returnString = "\(returnString) left"
            }
            
            if HLLDefaults.statusItem.showEndTime == true, countdownEvent.endDate.midnight() == Date().midnight() {
                
                returnString = "\(returnString) (\(countdownEvent.endDate.formattedTime()))"
                
            }
            
            if let percent = pecentageCalc.calculatePercentageDone(event: countdownEvent, ignoreDefaults: false), HLLDefaults.statusItem.showPercentage == true {
                
                returnString += " (\(percent))"
                
            }
            
            return returnString
            
        } else {
            
            return nil
        }
        
        
        
    }
    
    func generateCurrentEventStrings(currentEvents: [HLLEvent], nextEvents: [HLLEvent], allUpcoming: [HLLEvent]?) -> [(String, String?, HLLEvent?, HLLEvent?)] {
        
        var returnArray = [(String, String?, HLLEvent?, HLLEvent?)]()
        
        if currentEvents.isEmpty == false {
            
            for event in currentEvents {
                
                var percentText: String?
                
                let returnText = generateRegularCountdownText(event: event)
                
                if let percent = pecentageCalc.calculatePercentageDone(event: event, ignoreDefaults: false), HLLDefaults.general.showPercentage {
                    
                    percentText = "(\(percent))"
            
                }
                
                if let allU = allUpcoming {
                
                
                if let nextOccur = nextOccurFind.findNextOccurrences(currentEvents: [event], upcomingEvents: allU).first {
                    
                    returnArray.append((returnText, percentText, event, nextOccur))
                    
                } else {
                    
                    returnArray.append((returnText, percentText, event, nil))
                    
                }
                
                } else {
                    
                    returnArray.append((returnText, percentText, event, nil))
                    
                }
                
                
            }
            
            
        } else {
           
            returnArray.append(("No events are on right now.", nil, nil, nil))
            
        }
        
        return returnArray
        
    }
    
    func genTimerString(date: Date) -> String {
        
        let secondsLeft = date.timeIntervalSince(Date()).rounded(.down)
        
        //print("Secs: \(secondsLeft)")
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        
        if secondsLeft > 86399 {
            
            formatter.allowedUnits = [.day]
            
        } else if secondsLeft > 3600 {
            
            if HLLDefaults.statusItem.hideTimerSeconds == true {
                
                formatter.allowedUnits = [.hour, .minute]
                
                
            } else {
                
                
                formatter.allowedUnits = [.hour, .minute, .second]
                
            }
            
            
            
        } else {
            
            if HLLDefaults.statusItem.hideTimerSeconds == true {
                
                formatter.allowedUnits = [.hour, .minute]
                
            } else {
                
                formatter.allowedUnits = [.minute, .second]
                
            }
            
            
        }
        formatter.zeroFormattingBehavior = [ .dropLeading ]
        return formatter.string(from: secondsLeft+1)!
        
        
        
    }
    
    func generateCountdownNotificationStrings(event: HLLEvent) -> (String, String?) {
 
        return (generateRegularCountdownText(event: event), pecentageCalc.calculatePercentageDone(event: event, ignoreDefaults: false))
        
    }
 
    
   private func generateRegularCountdownText(event: HLLEvent) -> String {
        
    let secondsLeft = event.endDate.timeIntervalSinceNow
    
    let formatter = DateComponentsFormatter()
    
    if secondsLeft > 86399 {
        formatter.allowedUnits = [.day]
        
    } else {
        
        formatter.allowedUnits = [.hour, .minute]
        
    }
    
    formatter.unitsStyle = .full
    let countdownText = formatter.string(from: TimeInterval(secondsLeft+59))!
    
    if event.endDate.midnight() == Date().midnight() {
    
        return "\(event.title) \(event.endsInString) in \(countdownText), at \(event.endDate.formattedTime())."
        
    } else {
        
        return "\(event.title) \(event.endsInString) in \(countdownText)."
        
    }
    
    }
    

    
}
