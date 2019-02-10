//
//  EventCache.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 15/12/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

struct EventCache {
    
    static var currentEvents = [HLLEvent]()
    static var allUpcomingEvents = [HLLEvent]()
    static var allEventsToday = [HLLEvent]()
    static var upcomingEventsToday = [HLLEvent]()
    static var nextUpcomingEvents = [HLLEvent]()
    static var nextUpcomingEventsDay = [HLLEvent]()
    static var upcomingWeekEvents = [Date:[HLLEvent]]()
    static var primaryEvent: HLLEvent?
    
}
