//
//  EventCountdownTimerStringGenerator.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 21/1/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventCountdownTimerStringGenerator {
    
  /*  private var timer: Timer!
    var event: HLLEvent
    var delegate: CountdownUI
    
    init(event countdownEvent: HLLEvent, delegate UIDelegate: CountdownUI) {
        
        event = countdownEvent
        delegate = UIDelegate
        
        timer = Timer(fire: Date(), interval: 0.1, repeats: true, block: {_ in
            
            DispatchQueue.main.async {
                self.updateTimer()
            }
            
        })
        
        RunLoop.main.add(timer, forMode: .default)
        
    }
    
    func updateTimer() {
        
        let countdownString = generateStringFor(event: event)
        delegate.setCountdownString(to: countdownString)
        
    } */
    
    func generateStringFor(event: HLLEvent, start: Bool = false, advanceBySeconds: Int = 0) -> String? {
        
        var returnString: String?
        
        var secondsLeft: TimeInterval
        
        if start == true {
            
           secondsLeft = event.startDate.timeIntervalSince(Date()).rounded(.down)
            
        } else {
            
            secondsLeft = event.endDate.timeIntervalSince(Date()).rounded(.down)
            
        }
        
        secondsLeft -= Double(advanceBySeconds)
        
        if secondsLeft > -2 {
            
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
            
            returnString = "\(formattedDuration!)"
            
            
        }
        
        return returnString
        
    }
    
    
}

class AutomaticTimerStringGenerator {
    
    var date: Date?
    let formatter = DateComponentsFormatter()
    
    private var timer: Timer!
    private var delegate: CountdownUI
    
    
    
     init(date countdownDate: Date? = nil, delegate UIDelegate: CountdownUI) {
     
     date = countdownDate
     delegate = UIDelegate
        formatter.unitsStyle = .positional
     
     timer = Timer(fire: Date(), interval: 0.1, repeats: true, block: {_ in
     
     DispatchQueue.main.async {
     self.updateTimer()
     }
     
     })
     
     RunLoop.main.add(timer, forMode: .default)
     
     }
    
     
     func updateTimer() {
     
        var timerString = ""
        
        if let safeDate = date {
          timerString = generateStringFor(date: safeDate)
            
        }
        
     delegate.setCountdownString(to: timerString)
     
     
     }
    
    private func generateStringFor(date: Date) -> String {
        
        var returnString = ""
        
        
        let secondsLeft = date.timeIntervalSince(Date()).rounded(.down)
       
        
        if secondsLeft > -1 {
            
            
            
            if secondsLeft+1 > 86400 {
                
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                
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

protocol CountdownUI {
    
    func setCountdownString(to: String)
    
    
}
