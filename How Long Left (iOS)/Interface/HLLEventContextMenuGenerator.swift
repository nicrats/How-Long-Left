//
//  HLLEventContextMenuGenerator.swift
//  How Long Left (iOS)
//
//  Created by Ryan Kontos on 19/10/19.
//  Copyright © 2019 Ryan Kontos. All rights reserved.
//

import Foundation
import UIKit
import EventKit

@available(iOS 13.0, *)
class HLLEventContextMenuGenerator {
    
    static var shared = HLLEventContextMenuGenerator()
    
    func generateContextMenuForEvent(_ event: HLLEvent) -> UIMenu? {
        
        var actions = [UIAction]()
        
        if let calendarEvent = event.EKEvent {
            
            let editAction = UIAction(title: "Edit Calendar Event", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil, state: .off, handler: { _ in

                    EKEventViewControllerManager.shared.presentEventViewControllerFor(calendarEvent)
                

            })
            
            actions.append(editAction)
            
            
            
            let calendarAction = UIAction(title: "Hide Events From \"\(calendarEvent.calendar!.title)\"", image: UIImage(systemName: "calendar"), identifier: nil, discoverabilityTitle: nil, state: .off, handler: { _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                
                let selectedCalendar = calendarEvent.calendar!.calendarIdentifier
                
                    if let index = HLLDefaults.calendar.enabledCalendars.firstIndex(of: selectedCalendar) {
                        HLLDefaults.calendar.enabledCalendars.remove(at: index)
                    }
                    
                    if !HLLDefaults.calendar.disabledCalendars.contains(selectedCalendar) {
                        HLLDefaults.calendar.disabledCalendars.append(selectedCalendar)
                    }
                   
                
                HLLEventSource.shared.updateEventPool()
                
                })

            })
            
            actions.append(calendarAction)
            
            
            
        }
        
        
        if let visibilityItem = event.visibilityString {
            
            let action = UIAction(title: visibilityItem.rawValue, image: UIImage(systemName: "eye.slash.fill"), identifier: nil, discoverabilityTitle: nil, state: .off, handler: { _ in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    EventVisibiltyActionHandler.shared.disableVisbiltyFor(visibilityItem)
                })

            })

            
            actions.append(action)
            
            
            
            
        }
        
        return UIMenu(title: "", children: actions)
        
    }
    
   
    
}
