//
//  DateOfEvents.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 16/7/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

struct DateOfEvents: Equatable {
    
    var date: Date
    var events: [HLLEvent]
    
    init(date: Date, events: [HLLEvent]) {
        
        self.date = date
        self.events = events
        
    }
    
    
}
