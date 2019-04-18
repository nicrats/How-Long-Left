//
//  SiriResponseGenerator.swift
//  How Long Left Siri Extension
//
//  Created by Ryan Kontos on 28/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SiriResponseGenerator {
    
    let calendar = EventDataSource()
    
    
    
    
    
    func generateResponseForCurrentEvent() -> String {
        
        if let currentEvent = calendar.getCurrentEvent() {
            
            
            let title = currentEvent.title
            let remaining = generateTimeRemaining(currentEvent)
            
            let eventOnResponses = [
                
            "\(title) \(currentEvent.endsInString) in \(remaining).",
                
            "There's \(remaining) left of \(title).",
                
            "There's \(remaining) until \(title) finishes.",
            
            ]
                
            
            
            return eventOnResponses.randomElement()!
            
            
        } else {
            
            let noEventOnResponses = [
                
                "No events are on right now.",
                
                "There are no events on right now.",
                
                "No events are running right now.",
                
            ]
            
            return noEventOnResponses.randomElement()!
            
            
        }
        
        
    }
    
    
    
    private func generateTimeRemaining(_ event: HLLEvent) -> String {
        
        
        let currentEvent = event
        var secondsLeft = currentEvent.endDate.timeIntervalSinceNow
        
        let formatter = DateComponentsFormatter()
        
        secondsLeft -= 2
        
        if secondsLeft+1 > 86400 {
            
            secondsLeft += 86400
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            
        } else if secondsLeft+1 > 3599 {
            
            formatter.allowedUnits = [.hour, .minute, .second]
            
        } else {
            
            formatter.allowedUnits = [.minute, .second]
            
        }
        
         formatter.unitsStyle = .full
        
        var countdownText = formatter.string(from: secondsLeft+1)!
        
        if countdownText.last == "." {
            countdownText = String(countdownText.dropLast())
        }
        
        
        return "\(countdownText)"
        
        
    }
    
    
}
