//
//  SchoolEventModifier.swift
//  How Long Left
//
//  Created by Ryan Kontos on 18/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolEventModifier {
  
    func modify(events: [HLLEvent], addBreaks: Bool) -> [HLLEvent] {
        
        let magdaleneEventTitleShortener = EventTitleShortener()
        
        let timeAdjuster = EventTimeAdjuster()
        let periods = MagdalenePeriods()
        let breaks = MagdaleneBreaks()
        
        var returnArray = [HLLEvent]()
            
        switch SchoolAnalyser.schoolMode {
        
        case .Magdalene:
            
            var tempArray = [HLLEvent]()
            
            tempArray = timeAdjuster.adjustTime(events: events)
            
            if addBreaks {
            tempArray.append(contentsOf: breaks.getBreaks(events: tempArray))
            }
            
            tempArray = periods.magdalenePeriodFor(events: tempArray)
            tempArray = magdaleneEventTitleShortener.shortenTitle(events: tempArray)
           
            returnArray = tempArray
            
        default:
            
            returnArray = events
        
        }
        
        return returnArray
        
    }
    
}
