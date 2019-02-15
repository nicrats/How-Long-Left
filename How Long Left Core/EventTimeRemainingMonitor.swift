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

    var checkqueue = DispatchQueue(label: "CheckQueue")
    var countdownEvents = [HLLEvent]()
    var checkTimer = Timer()
    var delegate: HLLCountdownController
    let cal = EventDataSource.shared
    var coolingDown = [HLLEvent]()
    var coolingDownPercentage = [HLLEvent:Int]()
    var coolingDownEnded = [HLLEvent]()
    var coolingDownStarted = [HLLEvent]()
    let percentCalc = PercentageCalculator()
    
    init(delegate theDelegate: HLLCountdownController) {
        
        delegate = theDelegate
        
    }
    
    func setCurrentEvents(events: [HLLEvent]) {
        checkqueue.async(flags: .barrier) {
        
            self.countdownEvents = events
            
        }
    }
    
    func removeAllCurrentEvents() {
        checkqueue.async(flags: .barrier) {
        
            self.countdownEvents.removeAll()
            
        }
        
    }
    
    @objc func checkCurrentEvents() {
        
        checkqueue.async(flags: .barrier) {
        
        let milestones = HLLDefaults.notifications.milestones
        let percentageMilestones = HLLDefaults.notifications.Percentagemilestones
        
        var events = [HLLEvent]()
        
        #if os(iOS) || os(watchOS)
        
        events = countdownEvents
        
        #elseif os(OSX)
        
        events = EventCache.currentEvents
        
        #endif
        
        for event in events {
            
            
            let timeUntilEnd = event.endDate.timeIntervalSinceNow
            let timeUntilStart = event.startDate.timeIntervalSinceNow
            let secondsUntilEnd = Int(timeUntilEnd)
            
                for milestone in milestones {
                    
                    
                    if secondsUntilEnd == milestone {
                        
                        
                        if milestones.contains(milestone), self.coolingDown.contains(event) == false {
                            
                            self.coolingDown.append(event)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.coolingDown.removeAll()
                            }
                            
                            self.delegate.milestoneReached(milestone: milestone, event: event)
                            
                        
                        }
                        
                    }
                
                }
            
            let secondsElapsed = Date().timeIntervalSince(event.startDate)
            let totalSeconds = event.endDate.timeIntervalSince(event.startDate)
            let percentOfEventComplete = Int(100*secondsElapsed/totalSeconds)
            
            for percentageMilestone in percentageMilestones {
                
                if percentOfEventComplete == percentageMilestone {

                    if self.coolingDownPercentage[event] != percentageMilestone {
                        
                        self.delegate.percentageMilestoneReached(milestone: percentageMilestone, event: event)
                        self.coolingDownPercentage[event] = percentageMilestone
                        
                    }
                    
                
                }
                
            }

            
            if timeUntilEnd < 1, self.coolingDownEnded.contains(event) == false {
                    
                    print("\(event.title) is ending.")
                    
                    var endingNow = true
                    if timeUntilEnd < -5 {
                        endingNow = false
                    }
                self.delegate.updateDueToEventEnd(event: event, endingNow: endingNow)
                    
                self.coolingDownEnded.append(event)
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
            
            if timeUntilStart < 1, timeUntilStart > -10, self.coolingDownStarted.contains(event) == false, startedAtEndOfEvent == false {
                
                print("\(event.title) is starting.")
                
                self.delegate.eventStarted(event: event)
                
                self.coolingDownStarted.append(event)
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    self.coolingDownStarted.removeAll()
                }
                
                
            }

            
            
            
            }
            
        }
        
    }
    
}
