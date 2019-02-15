//
//  EventTitleShortener.swift
//  How Long Left
//
//  Created by Ryan Kontos on 16/10/18.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

class EventTitleShortener {
    
    static let shared = EventTitleShortener()
    
    func shortenTitle(events: [HLLEvent]) -> [HLLEvent] {
        
        if HLLDefaults.magdalene.shortenTitles == false {
            return events
        }
        
        var returnArray = [HLLEvent]()
        
        for eventItem in events {
        
            var event = eventItem
            
        var newTitle = event.originalTitle
        
        if event.originalTitle.contains(text:"Pastoral Care") {
            newTitle = "Homeroom"
        }
        
        if event.originalTitle.contains(text:"Information Software Technology") {
            newTitle = "IST"
        }
            
        if event.originalTitle.contains(text:"Information Process Technology") {
            newTitle = "IPT"
        }
           
        if event.originalTitle.contains(text:"Design"), event.originalTitle.contains(text:"Technology")  {
            newTitle = "D&T"
        }
            
        if event.originalTitle.contains(text:"Software Design") {
            newTitle = "SDD"
        }
            
        if event.originalTitle.contains(text:"Commerce") {
            newTitle = "Commerce"
        }
            
        if event.originalTitle.contains(text:"Arts") {
            newTitle = "Art"
        }
            
        if event.originalTitle.contains(text:"Drama") {
            newTitle = "Drama"
        }
            
        if event.originalTitle.contains(text:"PASS") {
            newTitle = "PASS"
        }
            
        if event.originalTitle.contains(text:"Food Technology") {
            newTitle = "Food Tech"
        }
        
        if event.originalTitle.contains(text:"SPORT:") {
            newTitle = "Sport"
        }
        
        if event.originalTitle.contains(text:"English") {
            newTitle = "English"
        }
        
        if event.originalTitle.contains(text:"Science") {
            newTitle = "Science"
        }
        
        if event.originalTitle.contains(text:"HSIE") {
            newTitle = "History"
        }
        
        if event.originalTitle.contains(text:"History") {
            newTitle = "History"
        }
        
        if event.originalTitle.contains(text:"History Elective") {
            newTitle = "HEL"
        }
        
        if event.originalTitle.contains(text:"Music") {
            newTitle = "Music"
        }
        
        if event.originalTitle.contains(text:"Maths") {
            newTitle = "Maths"
        }
        
        if event.originalTitle.contains(text:"Mathematics") {
            newTitle = "Maths"
        }
        
        if event.originalTitle.contains(text:"PDHPE") {
            newTitle = "PDHPE"
        }
        
        if event.originalTitle.contains(text:"Geography Elective") {
            newTitle = "GEL"
        }
        
        if event.originalTitle.contains(text:"GEL") {
            newTitle = "GEL"
        }
        
        if event.originalTitle.contains(text:"IST") {
            newTitle = "IST"
        }
        
        if event.originalTitle.contains(text:"Religion") {
            newTitle = "Religion"
        }
            
        if event.originalTitle.contains(text:"Chemistry") {
            newTitle = "Chemistry"
        }
            
        if event.originalTitle.contains(text:"Biology") {
            newTitle = "Biology"
        }
        
        if event.originalTitle.contains(text:"Physics") {
            newTitle = "Physics"
        }
            
        if event.originalTitle.contains(text:"Photography") {
            newTitle = "Photography"
        }
        
        if event.originalTitle.contains(text:"Study") {
            newTitle = "Study Period"
        }
        
        if event.originalTitle.contains(text:"Drama") {
            newTitle = "Drama"
        }
            
        if event.originalTitle.contains(text:"Legal Studies") {
            newTitle = "Legal Studies"
        }
            
        event.title = newTitle
        event.shortTitle = newTitle
            
        returnArray.append(event)
            
        }
        
        return returnArray
        
    }
    
}
