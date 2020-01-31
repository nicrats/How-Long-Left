//
//  CountdownStringGenerator.swift
//  How Long Left
//
//  Created by Ryan Kontos on 30/10/18.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

class CountdownStringGenerator {
    
    let pecentageCalc = PercentageCalculator()
    
    func generateStatusItemString(event: HLLEvent?, mode: StatusItemMode) -> String? {
        
        var returnVal: String?
        
        if let event = event {
        
        switch mode {
        case .Off:
            break
        case .Timer:
            returnVal = generateStatusItemPositionalString(event: event)
        case .Minute:
            returnVal = generateStatusItemMinuteModeString(event: event)
        }
            
        }
        
        return returnVal
        
    }
    
    
    func generateStatusItemPositionalString(event: HLLEvent) -> String {
            
        let returnString = generatePositionalCountdown(event: event)
        return modifyForUserStatusItemPreferences(string: returnString, event: event)
        
    }
    
    
    func generatePositionalCountdown(event: HLLEvent, allowFullUnits: Bool = false) -> String {
        
        var secondsLeft = event.countdownDate.timeIntervalSinceNow
        secondsLeft.round(.down)
        
        if secondsLeft < 0 {
            secondsLeft = -1
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        
        if secondsLeft < 60 {
            
            formatter.zeroFormattingBehavior = [ .pad ]
            
        } else {
            
           formatter.zeroFormattingBehavior = [ .default ]
            
        }
    
        if secondsLeft >= TimeInterval.year {
            
            formatter.allowedUnits = [.year]
            secondsLeft += TimeInterval.year
            formatter.unitsStyle = .abbreviated
            
        } else if secondsLeft >= TimeInterval.week {
            
            formatter.allowedUnits = [.day, .weekOfMonth]
            secondsLeft += TimeInterval.day
            
        } else if secondsLeft >= TimeInterval.day {
            
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            secondsLeft += TimeInterval.second
            
        } else {
            
            if HLLDefaults.statusItem.hideTimerSeconds == true {
                
                formatter.allowedUnits = [.hour]
                secondsLeft += TimeInterval.minute
                formatter.unitsStyle = .abbreviated
                
            } else {
                
                
                formatter.allowedUnits = [.second]
                secondsLeft += TimeInterval.second
                
                
            }
            
            if secondsLeft >= TimeInterval.hour {
            
            formatter.allowedUnits.insert(.hour)
            formatter.allowedUnits.insert(.minute)
            
        } else {
            
            formatter.allowedUnits.insert(.minute)
            
        }
            
            
        }
        
        if allowFullUnits, !formatter.allowedUnits.contains(.second), !formatter.allowedUnits.contains(.minute), !formatter.allowedUnits.contains(.hour) {

            formatter.unitsStyle = .full
            
        }
        
        
        return formatter.string(from: secondsLeft)!
    
    }

    
    func generateStatusItemMinuteModeString(event: HLLEvent) -> String {
        
        var secondsLeft: TimeInterval
        
        if event.completionStatus == .Upcoming {
            
            secondsLeft = event.startDate.timeIntervalSinceNow
            
        } else {
            
            secondsLeft = event.endDate.timeIntervalSinceNow
            
        }
        
        secondsLeft.round(.down)
        
        var returnString: String
            
        let formatter = DateComponentsFormatter()
        
        if HLLDefaults.statusItem.useFullUnits == true {
            formatter.unitsStyle = .full
        } else {
            formatter.unitsStyle = .abbreviated
        }
        
        if secondsLeft >= TimeInterval.year {
            
            formatter.allowedUnits = [.year]
            secondsLeft += TimeInterval.year
            
        } else if secondsLeft >= TimeInterval.week {
            
            formatter.allowedUnits = [.day, .weekOfMonth]
            secondsLeft += TimeInterval.day
            
        } else if secondsLeft >= TimeInterval.day {
            
            formatter.allowedUnits = [.day, .hour, .minute]
            secondsLeft += TimeInterval.minute
            
        } else {
            
        secondsLeft += TimeInterval.minute
            
        if secondsLeft >= TimeInterval.hour {
            
            formatter.allowedUnits = [.minute, .hour]
            
            
            
        } else {
           
            formatter.allowedUnits = [.minute]
            
        }
            
        }
            
        var countdownText = formatter.string(from: secondsLeft)!
            
        if countdownText.last == "." {
            countdownText = String(countdownText.dropLast())
        }
            
        returnString = modifyForUserStatusItemPreferences(string: countdownText, event: event)
        
        return returnString
 
    }
    
    
    func modifyForUserStatusItemPreferences(string: String, event: HLLEvent) -> String {
        
        var returnString = string
        
        if event.completionStatus == .Upcoming {
            returnString = "in \(returnString)"
            
        }
        
        if HLLDefaults.statusItem.showTitle == true {
            returnString = "\(event.title.truncated(limit: 15, position: .middle, leader: "...")): \(returnString)"
        }
        
        if HLLDefaults.statusItem.showLeftText == true, event.completionStatus != .Upcoming {
            
            returnString = "\(returnString) left"
        }
        
        if HLLDefaults.statusItem.showEndTime == true {
            
            var date = event.endDate
            
            if event.completionStatus == .Upcoming {
                
                date = event.startDate
                
            }
            
            returnString = "\(returnString) (\(date.formattedTime()))"
            
        }
        
        if HLLDefaults.statusItem.showPercentage == true, event.completionStatus != .Upcoming {
            let percent = pecentageCalc.calculatePercentageDone(for: event)
            returnString = "\(returnString) (\(percent))"
        }
        
        
        
        return returnString
        
    }
    
    enum EventDate {
        case Start
        case End
    }
    
    func generateCountdownTextFor(event: HLLEvent, currentDate: Date = Date(), showEndTime: Bool
        = true, force: EventDate? = nil, round: Bool = true) -> CountdownText {
        
        var mainText: String
        var percentText: String?
        
        var secondsLeft: TimeInterval
        
        if event.completionStatus == .Upcoming {
            
            secondsLeft = event.startDate.timeIntervalSince(currentDate)
            
        } else {
            
            secondsLeft = event.endDate.timeIntervalSince(currentDate)
            
        }
        
        if let safeForce = force {
            
            if safeForce == .Start {
                
                secondsLeft = event.startDate.timeIntervalSince(currentDate)
                
            }
            
            if safeForce == .End {
                
                secondsLeft = event.endDate.timeIntervalSince(currentDate)
                
            }
            
        }
        
        let formatter = DateComponentsFormatter()
        
        if secondsLeft >= TimeInterval.year {
            
            formatter.allowedUnits = [.year]
            if round {
            secondsLeft += TimeInterval.year
            }
            
        } else if secondsLeft >= TimeInterval.week {
            
            formatter.allowedUnits = [.day, .weekOfMonth]
            secondsLeft += TimeInterval.day
            
        } else if secondsLeft >= TimeInterval.day {
            
            formatter.allowedUnits = [.day, .hour]
            if round {
            secondsLeft += TimeInterval.hour
            }
            
        } else {
            
            if round {
            secondsLeft += TimeInterval.minute
            }
            
            if secondsLeft >= TimeInterval.hour {
                
                formatter.allowedUnits = [.minute, .hour]
                
            } else {
                
                formatter.allowedUnits = [.minute]
                
            }
            
        }
        
        formatter.unitsStyle = .full
        let countdownText = formatter.string(from: TimeInterval(secondsLeft))!
        
        let title = event.title.truncated(limit: 25, position: .middle, leader: "...")
        
        if event.endDate.startOfDay() == Date().startOfDay(), showEndTime == true {
            
            mainText = "\(title) \(event.countdownTypeString) in \(countdownText), at \(event.endDate.formattedTime())."
            
        } else {
            
            mainText = "\(title) \(event.countdownTypeString) in \(countdownText)."
            
        }
        
        
        if HLLDefaults.general.showPercentage {
            
            let percent = event.completionPercentage
            percentText = "\(percent)"
            
        }
        
        return CountdownText(mainText: mainText, percentageText: percentText, justCountdown: countdownText)
        
    }
    
}
