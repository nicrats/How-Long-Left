//
//  How_Long_Left_Helper.swift
//  How Long Left Helper
//
//  Created by Ryan Kontos on 13/2/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class HLLHelper: NSObject, HLLHelperProtocol {
    
    
    func updateEventStore() {
        
       dataSource.updateEventStore()
        
    }
    
    func analyseScholMode(withReply reply: @escaping (SchoolMode) -> Void) {
        
        SchoolAnalyser.shared.analyseCalendar()
        reply(SchoolAnalyser.privSchoolMode)
        
    }
    
    override init() {
        dataSource.getCalendarAccess()
    }
    
    let dataSource = EventDataSource()
    
    func getEventsFromCalendar(start: Date, end: Date, withReply reply: @escaping ([Data]) -> Void) {
        
        reply(convertToData(HLLEvents: dataSource.getEventsFromCalendar(start: start, end: end)))
        
    }
    
    func fetchEventsFromPresetPeriod(period: EventFetchPeriod, withReply reply: @escaping ([Data]) -> Void) {
        
        reply(convertToData(HLLEvents: dataSource.fetchEventsFromPresetPeriod(period: period)))
        
    }
    
    func getCurrentEvent(withReply reply: @escaping (Data?) -> Void) {
        
        reply(convertToData(HLLEvent: dataSource.getCurrentEvent()))
        
    }
    
    func getCurrentEvents(withReply reply: @escaping ([Data]) -> Void) {
        
        dataSource.updateEventStore()
        reply(convertToData(HLLEvents: dataSource.getCurrentEvents()))
    }
    
    func getUpcomingEventsToday(withReply reply: @escaping ([Data]) -> Void) {
        reply(convertToData(HLLEvents: dataSource.getUpcomingEventsToday()))
    }
    
    func getUpcomingEventsFromNextDayWithEvents(withReply reply: @escaping ([Data]) -> Void) {
        reply(convertToData(HLLEvents: dataSource.getUpcomingEventsFromNextDayWithEvents()))
    }
    
    func getArraysOfUpcomingEventsForNextSevenDays(withReply reply: @escaping ([Date : [Data]]) -> Void) {
        
        var returnDict = [Date : [Data]]()
        
        let eventData = dataSource.getArraysOfUpcomingEventsForNextSevenDays()
        
        for item in eventData {
            
            returnDict[item.key] = convertToData(HLLEvents: item.value)
            
        }
        
        reply(returnDict)
        
    }
    
    
    func convertToData(HLLEvents: [HLLEvent]) -> [Data] {
        
        var replyData = [Data]()
        
        for event in HLLEvents {
            
            do { try  replyData.append(JSONEncoder().encode(event))  }
                
            catch { }
            
        }
        
        return replyData
        
    }
    
    func convertToData(HLLEvent: HLLEvent?) -> Data? {
        
        var replyData: Data?
        
        if let event = HLLEvent {
            
            do { try  replyData = JSONEncoder().encode(event)  }
                
            catch { }
            
        }
    
        return replyData
        
    }
    
}
