//
//  SchoolEventDetailIndexer.swift
//  How Long Left
//
//  Created by Ryan Kontos on 15/1/20.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation

class SchoolEventDetailIndexBuilder {
    
    static var shared = SchoolEventDetailIndexBuilder()
    
    var index = [String:SchoolEventDetails]()
    
    func buildIndexFrom(events: [HLLEvent]) {
        
        if HLLDefaults.magdalene.showChanges == false {
            index.removeAll()
            return
        }
        
        var eventsDictionary = [String:[HLLEvent]]()
        
        for event in events {
            
            if event.startDate.year() != Date().year() {
                continue
            }
            
            if eventsDictionary.keys.contains(event.schoolEventIdentifier) {
                
                if !eventsDictionary[event.schoolEventIdentifier]!.contains(event) {
                                   
                    var array = eventsDictionary[event.schoolEventIdentifier]!
                    array.append(event)
                    eventsDictionary[event.schoolEventIdentifier] = array
        
                }
                               
            } else {
                
                eventsDictionary[event.schoolEventIdentifier] = [event]
                
            }
            
        }
        
        var newIndex = [String:SchoolEventDetails]()
        
        for item in eventsDictionary {
            
            
            var locationsArray = [String]()
            var teachersArray = [String]()
            
            for event in item.value {
                
                if let location = event.location {
                    locationsArray.append(location)
                }
                
                if let teacher = event.teacher {
                    teachersArray.append(teacher)
                }
                
            }
            
            let mostFrequentLocation = mostFrequent(array: locationsArray)
            let mostFrequentTeacher = mostFrequent(array: teachersArray)
            
            let object = SchoolEventDetails(location: mostFrequentLocation, teacher: mostFrequentTeacher)
            
            newIndex[item.key] = object
            
        }

        
        self.index = newIndex
        
    }
    
    func mostFrequent<T: Hashable>(array: [T]) -> T? {

        let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return counts.max(by: { $0.1 < $1.1 })?.key
         
    }
    
}

class SchoolEventDetails {
    
    var location: String?
    var teacher: String?
    
    internal init(location: String?, teacher: String?) {
        self.location = location
        self.teacher = teacher
    }
    
}


