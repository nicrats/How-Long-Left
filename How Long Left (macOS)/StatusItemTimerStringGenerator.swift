//
//  StatusItemTimerStringGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 21/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class StatusItemTimerStringGenerator {
    
    let percentageCalculator = PercentageCalculator()
    
    init (isForPreview: Bool) {
        
        if isForPreview == true {
            generateInAdvance = 0
        } else {
            generateInAdvance = 3
        }
        
    }
    
    
    let generateInAdvance: Int
    
    
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
                
                if HLLDefaults.statusItem.showTitle == true {
                    returnString = "\(event.shortTitle): \(returnString!)"
                }
                
                if HLLDefaults.statusItem.showLeftText == true {
                    returnString = "\(returnString!) left"
                }
                
                if HLLDefaults.statusItem.showPercentage == true, let percent = percentageCalculator.calculatePercentageDone(event: event) {
                    returnString = "\(returnString!) (\(percent))"
                }
                
            }
        
        return returnString
        
    }
    
    func generateStringsFor(event: HLLEvent) -> [Double: String] {
        
        var calcuatingFrom = Date()
        var returnItems: [Double: String] = [:]
        
        for _ in 1...generateInAdvance+1 {
            
            let secondsLeft = event.endDate.timeIntervalSince(calcuatingFrom).rounded(.down)
            
            if secondsLeft > -2 {
            
            let unixTime = calcuatingFrom.timeIntervalSince1970.rounded(.down)
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            
            if secondsLeft+1 > 86400 {
                    
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                    
            } else if secondsLeft+1 > 3599 {
                    
               formatter.allowedUnits = [.hour, .minute, .second]
                
            } else {
                
                formatter.allowedUnits = [.minute, .second]
            }
                
            formatter.zeroFormattingBehavior = [ .pad ]
            let formattedDuration = formatter.string(from: secondsLeft+1)
                
            var returnString = "\(formattedDuration!)"
                
            if HLLDefaults.statusItem.showTitle == true {
                returnString = "\(event.shortTitle): \(returnString)"
            }
                
            if HLLDefaults.statusItem.showLeftText == true {
                returnString = "\(returnString) left"
            }
                
            if HLLDefaults.statusItem.showPercentage == true, let percent = percentageCalculator.calculatePercentageDone(event: event) {
                returnString += " (\(percent))"
            }
                
            returnItems[unixTime] = returnString
            calcuatingFrom = calcuatingFrom.addingTimeInterval(1)
                
            }
            
        }
        
        return returnItems
        
    }
    
    
}
