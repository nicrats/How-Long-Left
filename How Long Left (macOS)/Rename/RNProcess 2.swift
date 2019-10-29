//
//  RNProcess.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 22/6/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import EventKit

class RNProcess {
    
    var cancelled = false
    
    deinit {
        cancelled = true
    }
    
    var previousProgress: Int?
    
var UIDelegate: RNProcessUI?
    
let access = EventDataSource()
    
    let renameStorage = RNDataStore()
    
    func run() {
        
        autoreleasepool {

            
            
        DispatchQueue.global(qos: .userInteractive).async {
            
            let renameItems = self.renameStorage.readEnabledItemsFromDefaults()
        var renameDictionary = [String:String]()
        
        for item in renameItems {
    
            renameDictionary[item.oldName] = item.newName
            
        }
            SchoolAnalyser().analyseCalendar()
            print("SA1")
            EventDataSource.eventStore.reset()
            let events = self.access.fetchEventsFromPresetPeriod(period: .ThisYear)
            let store = EventDataSource.eventStore
        
        var renameEvents = [HLLEvent]()
        
        for event in events {
            
            
            if renameDictionary.keys.contains(event.originalTitle) {
                
                renameEvents.append(event)
                
            }
            
        }
            
            if renameEvents.isEmpty == true {
                
                self.UIDelegate?.setProgress(100)
                self.UIDelegate?.setStatusString("No events to rename")
                return
                
            }
        
            self.UIDelegate?.log("Renaming \(renameEvents.count) events from \(renameEvents.first!.startDate.formattedDate()) to \(renameEvents.last!.endDate.formattedDate())")
        
        
       
        
            
            self.UIDelegate?.setStatusString("Renaming your events...")
            
            var breaksArray = [HLLEvent]()
            var dictOfDateArrays = [Date:[HLLEvent]]()
            
            
            for event in renameEvents {
                
                if dictOfDateArrays.keys.contains(event.startDate.midnight()) {
                    
                    dictOfDateArrays[event.startDate.midnight()]!.append(event)
                    
                    
                } else {
                    
                    dictOfDateArrays[event.startDate.midnight()] = [event]
                    
                }
                
                
            }
            
            if HLLDefaults.defaults.bool(forKey: "RNNoBreaks") == false {
            
            let breaks = MagdaleneBreaks()
            
            for item in dictOfDateArrays {
                
                breaksArray.append(contentsOf: breaks.getBreaks(events: item.value))
                print("Breaks: \(breaksArray.count)")
                
            }
                
            }
            
            
         let totalEvents = renameEvents.count + breaksArray.count
            
            var counter = 0
            
        HLLDefaults.defaults.set(0, forKey: "RenamedEvents")
            
        for (index, event) in renameEvents.enumerated() {
        
        let counterIndex = index+1
        
        if self.cancelled == true {
            
            print("Cancelling")
            return
            
        }
    
        if let newName = renameDictionary[event.originalTitle] {
            
            if let oldEk = event.EKEvent {
                oldEk.title = newName
                oldEk.calendar = event.calendar!
                oldEk.startDate = event.startDate
                oldEk.endDate = event.endDate
                
                do {
                    try store.save(oldEk, span: .thisEvent, commit: false)
                    //try store.remove(oldEk, span: .thisEvent, commit: true)
                    
                } catch {
                    
                    print("it didn't work because \(error)")
                }
                
                
                
                counter += 1
                
                let doubleCounter = Double(counter)
                let doubleTotal = Double(totalEvents)
                
                let progress = doubleCounter/doubleTotal*100
                
                self.UIDelegate?.log("Renamed \(counterIndex)/\(renameEvents.count) events: \(newName)")
                HLLDefaults.defaults.set(counterIndex, forKey: "RenamedEvents")
                self.UIDelegate?.setProgress(progress)
                
                
            }
            
        
            
        }
        
        
            
            
        }
            
            if breaksArray.isEmpty == false {
            
            self.UIDelegate?.setStatusString("Adding breaks...")
            //self.UIDelegate?.setProgress(0.0)
            
            HLLDefaults.defaults.set(0, forKey: "AddedBreaks")
            
            for (index, breakEvent) in breaksArray.enumerated() {
            
                let counterIndex = index+1
                
                let event = EKEvent(eventStore: store)
                event.title = breakEvent.title
                event.startDate = breakEvent.startDate
                event.endDate = breakEvent.endDate
                event.calendar = SchoolAnalyser.schoolCalendar
                
                do {
                   try store.save(event, span: .thisEvent, commit: false)
                   // try EventDataSource.eventStore.remove(oldEk, span: .thisEvent, commit: true)
                    
                } catch {
                    print("it didn't work")
                }
                
                counter += 1
                
                let doubleCounter = Double(counter)
                let doubleTotal = Double(totalEvents)
                
                let progress = doubleCounter/doubleTotal*100
                
                self.UIDelegate?.log("Added \(counterIndex)/\(breaksArray.count) breaks: \(breakEvent.title)")
                HLLDefaults.defaults.set(counterIndex, forKey: "AddedBreaks")
                
                let DBIProgress = Int(progress)
                
                if let prev = self.previousProgress {
                
                    if DBIProgress > prev {
                        
                        self.UIDelegate?.setProgress(Double(DBIProgress))
                        
                    }
                    
                } else {
                    
                    self.UIDelegate?.setProgress(Double(DBIProgress))
                    
                }
                
                self.previousProgress = DBIProgress
            }
            
            }
                
            self.UIDelegate?.processStateChanged(to: .Done)
            //self.UIDelegate?.setStatusString("Renaming complete")
        
    }
            
            
            
        }
        
    }
    
    
}
