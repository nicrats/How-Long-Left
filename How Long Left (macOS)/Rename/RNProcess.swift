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
            
            Main.isRenaming = true
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                HLLDefaults.defaults.set(0, forKey: "RenamedEvents")
                HLLDefaults.defaults.set(0, forKey: "AddedBreaks")
                
                self.UIDelegate?.setStatusString("Finding events to rename...")
                self.UIDelegate?.log("Starting RNProcess")
                let renameItems = self.renameStorage.readEnabledItemsFromDefaults()
                var renameDictionary = [String:String]()
                
                for item in renameItems {
                    
                    renameDictionary[item.oldName] = item.newName
                    
                }
                
                self.UIDelegate?.log("renameDictionary has \(renameDictionary.count) values")
                
                if renameDictionary.count == 0 {
                    
                    self.UIDelegate?.log("(That may be a problem)")
                    
                }
                
                SchoolAnalyser().analyseCalendar()
                print("SA1")
                EventDataSource.eventStore.reset()
                let events = self.access.fetchEventsFromPresetPeriod(period: .ThisYear)
                
                self.UIDelegate?.log("Found \(events.count) events")
                
                let store = EventDataSource.eventStore
                
                var renameEvents = [HLLEvent]()
                
                for event in events {
                    
                    if renameDictionary.keys.contains(event.originalTitle) {
                        
                        renameEvents.append(event)
                        
                    }
                    
                }
                
                self.UIDelegate?.log("Matched \(renameEvents.count) found events to a renameDictionaryItem")
                
                let doBreaks = !HLLDefaults.defaults.bool(forKey: "RNNoBreaks")

                self.UIDelegate?.log("doBreaks is \(doBreaks)")
                
                var breaksArray = [HLLEvent]()
                var dictOfDateArrays = [Date:[HLLEvent]]()
                
                var blockedLunchDates = [Date]()
                var blockedRecessDates = [Date]()
                
                for event in events {
                    
                    if event.title == "Lunch" {
                        
                        blockedLunchDates.append(event.startDate.midnight())
                        
                    }
                    
                    if event.title == "Recess" {
                        
                        blockedRecessDates.append(event.startDate.midnight())
                        
                    }
                    
                    if event.isSchoolEvent {
                        
                        if dictOfDateArrays.keys.contains(event.startDate.midnight()) {
                            
                            dictOfDateArrays[event.startDate.midnight()]!.append(event)
                            
                            
                        } else {
                            
                            dictOfDateArrays[event.startDate.midnight()] = [event]
                            
                        }
                        
                    }
                }
                
                
                
                if doBreaks {
                    
                    let breaks = MagdaleneBreaks()
                    
                    for item in dictOfDateArrays {
                        
                       let titles = item.value.map { $0.title }
                        
                        if titles.contains("Lunch") || titles.contains("Recess") == false {
                        
                            var dayBreaks = breaks.getBreaks(events: item.value)
                            
                            for breakEvent in dayBreaks {
                                
                                if breakEvent.title == "Lunch" {
                                    
                                    if blockedLunchDates.contains(breakEvent.startDate.midnight()) {
                                        
                                        if let index = dayBreaks.firstIndex(of: breakEvent) {
                                            
                                            dayBreaks.remove(at: index)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if breakEvent.title == "Recess" {
                                    
                                    if blockedRecessDates.contains(breakEvent.startDate.midnight()) {
                                        
                                        if let index = dayBreaks.firstIndex(of: breakEvent) {
                                            
                                            dayBreaks.remove(at: index)
                                            
                                        }
                                        
                                    }
                                    
                                }

                                
                            }
                            
                        breaksArray.append(contentsOf: dayBreaks)
                        
                        print("Breaks: \(breaksArray.count)")
                            
                        }
                        
                    }
                    
                    self.UIDelegate?.log("There are \(breaksArray.count) breaks to be created")
                    
                }
                
               
                
                if self.cancelled == true {
                    
                    store.reset()
                    print("Cancelling")
                    return
                    
                }
                
                if renameEvents.isEmpty == false {
                    
                
                let renamingStatusString: String
                
                if breaksArray.isEmpty == false {
                    
                    renamingStatusString = "Step 1/2: Renaming \(renameEvents.count) events..."
                    
                    
                } else {
                    
                    renamingStatusString = "Renaming \(renameEvents.count) events..."
                    
                }
                
                self.UIDelegate?.setStatusString(renamingStatusString)
                
                
                self.UIDelegate?.log("Renaming \(renameEvents.count) events from \(renameEvents.first!.startDate.formattedDate()) to \(renameEvents.last!.endDate.formattedDate())")
                
                
                for (index, event) in renameEvents.enumerated() {
                    
                    let renamedCount = index+1
                    
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
                                try store.save(oldEk, span: .thisEvent, commit: true)
                                //try store.remove(oldEk, span: .thisEvent, commit: true)
                                
                            } catch {
                                
                                print("it didn't work because \(error)")
                            }
                            
                            
                            
                            
                            let doubleCounter = Double(renamedCount)
                            let doubleTotal = Double(renameEvents.count)
                            
                            let progress = doubleCounter/doubleTotal*100
                            
                            self.UIDelegate?.log("Renamed \(renamedCount)/\(renameEvents.count) events: \(newName)")
                            HLLDefaults.defaults.set(renamedCount, forKey: "RenamedEvents")
                            self.UIDelegate?.setProgress(progress)
                            
                            
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                }
                    
                } else {
                    
                    self.UIDelegate?.setProgress(100)
                    self.UIDelegate?.setStatusString("No events to rename")
                    self.UIDelegate?.log("Aborting rename stage because there are no events to rename")
                    
                    if breaksArray.isEmpty == false {
                        
                        self.UIDelegate?.log("Will still continue to add breaks")
                        
                    }
                    
                    
                }
                
                if self.cancelled == true {
                    
                     store.reset()
                    print("Cancelling")
                    return
                    
                }
                
                if breaksArray.isEmpty == false {
                    
                    if renameEvents.isEmpty {
                        
                        self.UIDelegate?.setStatusString("Adding breaks...")
                        
                    } else {
                        
                        self.UIDelegate?.setStatusString("Step 2/2: Adding breaks...")
                        
                    }
                    
                    
                    //self.UIDelegate?.setProgress(0.0)
                    
                    HLLDefaults.defaults.set(0, forKey: "AddedBreaks")
                    
                    for (index, breakEvent) in breaksArray.enumerated() {
                        
                        let addedCount = index+1
                        
                        let event = EKEvent(eventStore: store)
                        event.title = breakEvent.title
                        event.startDate = breakEvent.startDate
                        event.endDate = breakEvent.endDate
                        event.calendar = SchoolAnalyser.schoolCalendar
                        
                        do {
                            try store.save(event, span: .thisEvent, commit: true)
                            // try EventDataSource.eventStore.remove(oldEk, span: .thisEvent, commit: true)
                            
                        } catch {
                            print("it didn't work")
                        }
                        
                        
                        let doubleCounter = Double(addedCount)
                        let doubleTotal = Double(breaksArray.count)
                        
                        let progress = doubleCounter/doubleTotal*100
                        
                        self.UIDelegate?.log("Added \(addedCount)/\(breaksArray.count) breaks: \(breakEvent.title)")
                        HLLDefaults.defaults.set(addedCount, forKey: "AddedBreaks")
                        
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
                
                
                if self.cancelled == true {
                    
                     store.reset()
                    print("Cancelling")
                    return
                    
                }
                
                self.UIDelegate?.processStateChanged(to: .Done)
                store.reset()
                Main.isRenaming = false
                //self.UIDelegate?.setStatusString("Renaming complete")
                
            }
            
            
            
        }
        
    }
    
    
}
