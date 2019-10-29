//
//  FollowingOccurenceStore.swift
//  How Long Left
//
//  Created by Ryan Kontos on 30/11/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation


class FollowingOccurenceStore {

    static var shared = FollowingOccurenceStore()
    
    let barrierQueue = DispatchQueue(label: "EventNextOccurenceStoreBarrierQueue")
    
    var nextOccurDictionary = [String:HLLEvent]()
    
    func updateNextOccurenceDictionary(events: [HLLEvent]) {
        
        self.nextOccurDictionary.removeAll()
        
        if HLLDefaults.general.showNextOccurItems == false {
            return
        }
        
        let sorted = events.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        
        for outerEvent in sorted {
            
            let dif = Date().timeIntervalSince(outerEvent.startDate)
            
            for innerEvent in sorted {
                
                
                
                let difFromEvent = innerEvent.endDate.timeIntervalSince(outerEvent.startDate)
                
                if innerEvent.title == outerEvent.title, nextOccurDictionary.keys.contains(innerEvent.identifier) == false, dif < 0, innerEvent.startDate != outerEvent.startDate, difFromEvent < 0, outerEvent.completionStatus == .Upcoming {
                        self.nextOccurDictionary[innerEvent.identifier] = outerEvent

                }
                
            }
                
        }
        
    }
    
    
}


