//
//  SchoolFunctionsManager.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolFunctionsManager {
  
    
    func handle(events: [HLLEvent]) -> [HLLEvent] {
        
        // let doubleEventDetector = DoubleEventDetector()
        let magdaleneEventTitleShortener = EventTitleShortener()
        let magdalenePeriods = MagdalenePeriods()
        let magdaleneBreaks = MagdaleneBreaks()
        let timeAdjuster = EventTimeAdjuster()
        
        // Manages school specific functions on EKEvents.
        
        var returnArray = [HLLEvent]()
            
        switch SchoolAnalyser.schoolMode {
        
        case .Magdalene:
            
            var tempArray = magdaleneEventTitleShortener.shortenTitle(events: events)
            // tempArray = doubleEventDetector.detectDoublesIn(events: tempArray)
            tempArray = timeAdjuster.adjustTime(events: tempArray)
            tempArray.append(contentsOf: magdaleneBreaks.getBreaks(events: tempArray))
            tempArray = magdalenePeriods.magdalenePeriodsFor(events: tempArray)
            
            if HLLDefaults.magdalene.hideNonMagdaleneEvents == true {
            
            for event in tempArray {
                
                if event.magdalenePeriod != nil {
                    
                    returnArray.append(event)
                    
                }
                
            }
            
            } else {
            
            returnArray = tempArray
                
            }
            
        case .Jasmine:
            
            returnArray = magdaleneEventTitleShortener.shortenTitle(events: events)
            
            
        default:
            
            returnArray = events
        
        }
        
        return returnArray
        
    }
    
}
