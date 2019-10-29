//
//  HLLEventInfoItemGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 27/9/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation

/**
* Fetch HLLEventInfoItem objects that describe a HLLEvent in a user friendly way.
*/

class HLLEventInfoItemGenerator {
    
    private var event: HLLEvent
    
    init(_ event: HLLEvent) {
        self.event = event
    }
    
    private let durationStringGenerator = DurationStringGenerator()
    private let percentageCalculator = PercentageCalculator()
    private let countdwonStringGenerator = CountdownStringGenerator()
    
    func getInfoItem(for type: HLLEventInfoItemType) -> HLLEventInfoItem? {
        
        var titleString: String?
        var infoString: String?
        
        switch type {
            
        case .completion:
        
            if event.completionStatus == .Current {
            titleString = "Completion"
            infoString = percentageCalculator.calculatePercentageDone(event: event, ignoreDefaults: true)
            }
            
        case .location:
            
            titleString = "Location"
            
            if let location = event.location {
                
                infoString = location
                
               if location.contains(text: "Room: ") {
                    
                    if let justRoom = location.components(separatedBy: "Room: ").last {
                        
                        infoString = "Room \(justRoom)"
                        titleString = "Room"
                        
                    }
                    
                }
                
            }
            
        case .period:
            
            titleString = "Period"
            
            if let period = event.period {
                
                infoString = "Period \(period)"
                
            }
            
        case .start:
            
           titleString = "Start"
           if event.completionStatus != .Upcoming {
                titleString = "Started"
           }
           
           infoString = "\(event.startDate.userFriendlyRelativeString()), \(event.startDate.formattedTime())"
            
        case .end:
            
            titleString = "End"
            if event.completionStatus == .Done {
                titleString = "Ended"
            }
            
            infoString = "\(event.endDate.userFriendlyRelativeString()), \(event.endDate.formattedTime())"
            
        case .elapsed:
        
            if event.completionStatus == .Current {
            
                    titleString = "Elapsed"
                    let secondsSinceStart = Date().timeIntervalSince(event.startDate)
                    infoString = durationStringGenerator.generateDurationString(for: secondsSinceStart)
                    
                }
                
                if event.completionStatus == .Done {
                    
                    titleString = "Finshed"
                    let secondsSinceEnd = Date().timeIntervalSince(event.endDate)
                    let duration = durationStringGenerator.generateDurationString(for: secondsSinceEnd)
                    infoString = "\(duration) ago"
                    
                }
            
        case .duration:
            
            titleString = "Duration"
            infoString = durationStringGenerator.generateDurationString(for: event.duration)
            
        case .calendar:
            
            titleString = "Calendar"
            if let calendar = event.calendar {
                infoString = calendar.title
            }
            
        case .teacher:
            
            titleString = "Teacher"
            
            if SchoolAnalyser.schoolMode == .Magdalene {
            
                if let ek = event.EKEvent, let notes = ek.notes {
                    
                    let lines = notes.split { $0.isNewline }
                
                    for line in lines {
                    
                        if line.contains("Teacher: "), let justTeacher = line.components(separatedBy: "Teacher: ").last {
                        
                            infoString = justTeacher.capitalized
                        
                        }
                    
                    }
                
                }
                
            }
            
        case .nextOccurence:
            
            titleString = "Following Occurrence"
            
            if let nextOccur = event.followingOccurence {
            
            var info = "\(nextOccur.startDate.userFriendlyRelativeString()), "
            
            if let period = nextOccur.period {
                
                info += "Period \(period)"
                
            } else {
                
                info += "\(nextOccur.startDate.formattedTime())"
                
            }
                
            infoString = info
                
            }
            
        case .countdown:
            
            if event.completionStatus != .Done {
            
            titleString = "\(event.countdownTypeString.capitalizingFirstLetter()) in"
            infoString = countdwonStringGenerator.generatePositionalCountdown(event: event)
                
            }
            
        }
        
        if let title = titleString, let info = infoString {
            return HLLEventInfoItem(title, info, type)
        } else {
            return nil
        }
        
    }
    
    func getInfoItems(for types: [HLLEventInfoItemType]) -> [HLLEventInfoItem] {
        
        var returnArray = [HLLEventInfoItem]()
        
        for type in types {
            
            if let item = getInfoItem(for: type) {
               
                returnArray.append(item)
                
            }
            
        }
        
        return returnArray
        
    }

}
