//
//  SchoolFunctionsManager.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolFunctionsManager {
    
  //  let doubleEventDetector = DoubleEventDetector()
   // let magdaleneEventTitleShortener = EventTitleShortener()
   // let magdalenePeriods = MagdalenePeriods()
   // let magdaleneBreaks = MagdaleneBreaks()
    
    func handle(events: [HLLEvent]) -> [HLLEvent] {
        
        // Manages school specific functions on EKEvents.
        
        var returnArray = [HLLEvent]()
            
        switch SchoolAnalyser.schoolMode {
        
        case .Magdalene:
            
            var tempArray = EventTitleShortener.shared.shortenTitle(events: events)
            // tempArray = doubleEventDetector.detectDoublesIn(events: tempArray)
            tempArray = EventTimeAdjuster.shared.adjustTime(events: tempArray)
            tempArray.append(contentsOf: MagdaleneBreaks.shared.getBreaks(events: tempArray))
            tempArray = MagdalenePeriods.shared.magdalenePeriodsFor(events: tempArray)
            
            if HLLDefaults.magdalene.hideNonMagdaleneEvents == true {
            
            for event in tempArray {
                
                if event.magdalenePeriod != nil {
                    
                    returnArray.append(event)
                    
                }
                
            }
            
            } else {
            
            returnArray = tempArray
                
            }
            
        default:
            
            returnArray = events
        
        }
        
        return returnArray
        
    }
    
}
