//
//  HLLEventUniversalMenuItemGenerator.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 23/12/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit

class HLLEventUniversalMenuItemGenerator {
    
    func generateUniversalMenuItems(for event: HLLEvent, isFollowingOccurence: Bool = false) -> [[UniversalMenuItem]] {
        
        var returnArray = [[UniversalMenuItem]]()
        
        var mainItems = [UniversalMenuItem]()
        
        if let calendarEvent = event.EKEvent {
            
            if calendarEvent.calendar.allowsContentModifications {
            
            let editItem = UniversalMenuItem(title: "Edit")
            
            if #available(iOS 13.0, *) {
                editItem.image = UIImage(systemName: "pencil")
            }
            
            editItem.action = {
                EKEventViewControllerManager.shared.presentEventViewControllerFor(calendarEvent)
            }
            
            mainItems.append(editItem)
                
            }
            
            let disableCalendarItem = UniversalMenuItem(title: "Disable Calendar")
            disableCalendarItem.secondaryTitle = calendarEvent.calendar!.title
            
            if #available(iOS 13.0, *) {
                disableCalendarItem.image = UIImage(systemName: "calendar")
            }
            
            disableCalendarItem.action = {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                
                let selectedCalendar = calendarEvent.calendar!.calendarIdentifier
                
                    if let index = HLLDefaults.calendar.enabledCalendars.firstIndex(of: selectedCalendar) {
                        HLLDefaults.calendar.enabledCalendars.remove(at: index)
                    }
                    
                    if !HLLDefaults.calendar.disabledCalendars.contains(selectedCalendar) {
                        HLLDefaults.calendar.disabledCalendars.append(selectedCalendar)
                    }
                   
                HLLDefaultsTransfer.shared.userModifiedPrferences()
                HLLEventSource.shared.updateEventPool()
                
                })
                
            }
            
            mainItems.append(disableCalendarItem)
            
            if let period = event.period, period == "S" {
                
                var title = "Show Sport as Study"
                var imageTitle = "book"
                if HLLDefaults.magdalene.showSportAsStudy {
                    title = "Show Sport as Sport"
                    imageTitle = "sportscourt"
                }
                
                let sportAsStudyItem = UniversalMenuItem(title: title)
                
                if #available(iOS 13.0, *) {
                    sportAsStudyItem.image = UIImage(systemName: imageTitle)
                }
                
                sportAsStudyItem.action = {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    
                    HLLDefaults.magdalene.showSportAsStudy = !HLLDefaults.magdalene.showSportAsStudy
                    HLLDefaultsTransfer.shared.userModifiedPrferences()
                    HLLEventSource.shared.asyncUpdateEventPool()
                        
                    })
                    
                }
                
                mainItems.append(sportAsStudyItem)
                
            }
            
        }
        
        if let visibilityString = event.visibilityString {
                
            let visibilityItem = UniversalMenuItem(title: visibilityString.rawValue)
            
            if #available(iOS 13.0, *) {
                visibilityItem.image = UIImage(systemName: "eye.slash.fill")
            }
            
            visibilityItem.action = {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    EventVisibiltyActionHandler.shared.disableVisbiltyFor(visibilityString)
                    HLLDefaultsTransfer.shared.userModifiedPrferences()
                })
                
            }
            
            mainItems.append(visibilityItem)
                   
        }
              
        returnArray.append(mainItems)
        
        if event.isAllDay {
                   
                   var allDayArray = [UniversalMenuItem]()
                   
                   let hideAllDayEventsItem = UniversalMenuItem(title: "Hide All-Day Events...")
                   
                   if #available(iOS 13.0, *) {
                       hideAllDayEventsItem.image = UIImage(systemName: "eye.slash.fill")
                   }
                   
                   hideAllDayEventsItem.action = {
                       
                    var style = UIAlertController.Style.actionSheet
                    #if targetEnvironment(macCatalyst)
                    style = .alert
                    #endif
                    
                    let actionSheet = UIAlertController(title: "Hide All-Day Events", message: nil, preferredStyle: style)
                    
                    let hideInCurrentTrigger = UIAlertAction(title: "In Current Events", style: .default, handler: { _ in
                                           
                                           HLLDefaults.general.showAllDayAsCurrent = false
                                           HLLDefaultsTransfer.shared.userModifiedPrferences()
                                           
                                       })
                                       
                                       actionSheet.addAction(hideInCurrentTrigger)
                    
                    let hideEverywhereTrigger = UIAlertAction(title: "Everywhere", style: .default, handler: { _ in
                        
                        HLLDefaults.general.showAllDay = false
                        HLLDefaultsTransfer.shared.userModifiedPrferences()
                    
                    })
                    
                    actionSheet.addAction(hideEverywhereTrigger)
                    
                   
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    actionSheet.addAction(cancel)
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(actionSheet, animated: true, completion: nil)
                    
                    
                       
                   }
                   
                   allDayArray.append(hideAllDayEventsItem)
            
                    returnArray.append(allDayArray)

               
                   
               }
               
        
        if isFollowingOccurence {
             
            var secondaryItems = [UniversalMenuItem]()
            
            let hideFollowingOccurencesItem = UniversalMenuItem(title: "Hide Following Occurences")
            
            if #available(iOS 13.0, *) {
                hideFollowingOccurencesItem.image = UIImage(systemName: "xmark.square")
            }
            
            hideFollowingOccurencesItem.action = {
                HLLDefaults.general.showNextOccurItems = false
                HLLDefaultsTransfer.shared.userModifiedPrferences()
            }
            
            secondaryItems.append(hideFollowingOccurencesItem)
            
            returnArray.append(secondaryItems)
                         
            }
        
        return returnArray
        
    }
    
}
