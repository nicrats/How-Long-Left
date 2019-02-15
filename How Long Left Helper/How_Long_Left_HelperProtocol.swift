//
//  How_Long_Left_HelperProtocol.h
//  How Long Left Helper
//
//  Created by Ryan Kontos on 13/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

@objc protocol HLLHelperProtocol {
    
    func updateEventStore()
    
    func analyseScholMode(withReply reply: @escaping (SchoolMode) -> Void)
    
    func getEventsFromCalendar(start: Date, end: Date, withReply reply: @escaping ([Data]) -> Void)
    func fetchEventsFromPresetPeriod(period: EventFetchPeriod, withReply reply: @escaping ([Data]) -> Void)
    func getCurrentEvent(withReply reply: @escaping (Data?) -> Void)
    func getCurrentEvents(withReply reply: @escaping ([Data]) -> Void)
    func getUpcomingEventsToday(withReply reply: @escaping ([Data]) -> Void)
    func getUpcomingEventsFromNextDayWithEvents(withReply reply: @escaping ([Data]) -> Void)
    func getArraysOfUpcomingEventsForNextSevenDays(withReply reply: @escaping ([Date : [Data]]) -> Void)
    
    
}
