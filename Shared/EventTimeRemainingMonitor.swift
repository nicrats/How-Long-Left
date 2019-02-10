//
//  EventTimeRemainingMonitor.swift
//  How Long Left
//
//  Created by Ryan Kontos on 22/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//
//  Monitors the time remaining of events.
//

import Foundation

class EventTimeRemainingMonitor {

    var countdownEvents = [HLLEvent]()
    var checkTimer = Timer()
    var delegate: HLLCountdownController
    let cal = EventDataSource.shared
    var coolingDown = [HLLEvent]()
    var coolingDownPercentage = [HLLEvent:Int]()
    var coolingDownEnded = [HLLEvent]()
    var coolingDownStarted = [HLLEvent]()
    
    init(delegate theDelegate: HLLCountdownController) {
        
        delegate = theDelegate
        
    }
    
    func setCurrentEvents(events: [HLLEvent]) {
        
        countdownEvents = events
       
    }
    
    func removeAllCurrentEvents() {
        
        countdownEvents.removeAll()
        
    }
    
    @objc func checkCurrentEvents() {
        
        let milestones = HLLDefaults.notifications.milestones
        let percentageMilestones = HLLDefaults.notifications.Percentagemilestones
        
        var events = [HLLEvent]()
        
        #if os(iOS) || os(watchOS)
        
        events = countdownEvents
        
        #elseif os(OSX)
        
        events = EventCache.currentEvents
        
        #endif
        
        for event in events {
            
            print("Milestone: Checking \(event.title)")
            
            let timeUntilEnd = event.endDate.timeIntervalSinceNow
            let timeUntilStart = event.startDate.timeIntervalSinceNow
            let secondsUntilEnd = Int(timeUntilEnd)
            
                for milestone in milestones {
                    
                    print("Milestone: Checking milestone \(milestone)")
                    
                    if secondsUntilEnd == milestone {
                        
                        print("Milestone: Matched milestone \(milestone) to \(event.title)")
                        
                        if milestones.contains(milestone), coolingDown.contains(event) == false {
                            
                            coolingDown.append(event)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.coolingDown.removeAll()
                            }
                            
                        delegate.milestoneReached(milestone: milestone, event: event)
                            
                        print("\(event.title) has reached milestone \(milestone/60).")
                        
                        }
                        
                    }
                
                }
            
            let secondsElapsed = Int(Date().timeIntervalSince(event.startDate))+1
            let totalSeconds = Int(event.endDate.timeIntervalSince(event.startDate))
            let percentOfEventComplete = 100*secondsElapsed/totalSeconds
            
            for percentageMilestone in percentageMilestones {
                
                if percentOfEventComplete == percentageMilestone {

                    if coolingDownPercentage[event] != percentageMilestone {
                        
                        delegate.percentageMilestoneReached(milestone: percentageMilestone, event: event)
                        coolingDownPercentage[event] = percentageMilestone
                        
                    }
                    
                
                }
                
            }

            
            if timeUntilEnd < 1, coolingDownEnded.contains(event) == false {
                    
                    print("\(event.title) is ending.")
                    
                    var endingNow = true
                    if timeUntilEnd < -5 {
                        endingNow = false
                    }
                    delegate.updateDueToEventEnd(event: event, endingNow: endingNow)
                    
                coolingDownEnded.append(event)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.coolingDownEnded.removeAll()
                    }
                    
                   
                }

            
            var startedAtEndOfEvent = false
            
            for eventToday in EventCache.allEventsToday {
                
                if eventToday.endDate == event.startDate {
                    
                    startedAtEndOfEvent = true
                    
                }
                
            }
            
            if timeUntilStart < 1, timeUntilStart > -10, coolingDownStarted.contains(event) == false, startedAtEndOfEvent == false {
                
                print("\(event.title) is starting.")
                
                delegate.eventStarted(event: event)
                
                coolingDownStarted.append(event)
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    self.coolingDownStarted.removeAll()
                }
                
                
            }

            
            
            
            }
        
    }
    
}
