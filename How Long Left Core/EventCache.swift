//
//  EventCache.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 15/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

struct EventCache {
    
    static var fetchQueue = DispatchQueue(label: "eventFetchQueue")
    
    static var currentEvents = [HLLEvent]()
    static var primaryEvent: HLLEvent?
    static var upcomingEventsToday = [HLLEvent]()
    static var allToday = [HLLEvent]()
    
}
