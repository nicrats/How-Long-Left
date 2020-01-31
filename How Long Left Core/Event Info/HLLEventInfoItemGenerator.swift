//
//  HLLEventInfoItemGenerator.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 27/9/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
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
            infoString = percentageCalculator.calculatePercentageDone(for: event)
            }
            
        case .location:
            
            titleString = "Location"
            
            if let location = event.location {
                
                infoString = location
                
               if location.contains(text: "Room: ") {
                    
                    if let justRoom = location.components(separatedBy: "Room: ").last {
                        
                        infoString = "\(justRoom)"
                        
                        if event.roomChange != nil {
                            titleString = "Room Change"
                        } else {
                            titleString = "Room"
                        }
                        
                        
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
            
            if event.teacherChange != nil {
                titleString = "Sub"
            } else {
                titleString = "Teacher"
            }
            
            if SchoolAnalyser.schoolMode == .Magdalene {
            
                if let teacher = event.teacher {
                   
                    infoString = teacher
                
                }
                
            }
            
        case .nextOccurence:
            
            titleString = "Following Occurrence"
            
            if HLLDefaults.general.showNextOccurItems == false {
                return nil
            }
            
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
            
        case .originalLocation:
            
            if let originalRoom = event.usualRoom, event.roomChange != nil {
                
                titleString = "Usual Room"
                
                infoString = originalRoom
                
                if let justRoom = originalRoom.components(separatedBy: "Room: ").last {
                   infoString = justRoom
                }
                
            } else {
                return nil
            }

            
        case .originalTeacher:
            
            titleString = "Usual Teacher"
            
            if SchoolAnalyser.schoolMode == .Magdalene {
            
                if let teacher = event.usualTeacher, event.teacherChange != nil {
                   
                    infoString = teacher
                
                }
                
            }
            
        case .oldLocationName:
            
            if event.oldLocationSetting == .replace {
                titleString = "New Name"
            }
            
            if event.oldLocationSetting == .showInSubmenu {
                titleString = "Old Name"
            }
            
            if let old = event.secondaryRoomName {
                
                if old.contains(text: "Room: ") {
                    
                    if let justRoom = old.components(separatedBy: "Room: ").last {
                        
                        infoString = "\(justRoom)"
                        
                    }
                    
                } else {
                    infoString = old
                }
                
                
                
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
