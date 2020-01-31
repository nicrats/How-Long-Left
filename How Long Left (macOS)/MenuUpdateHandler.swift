//
//  MenuUpdateHandler.swift
//  How Long Left (macOS)
//
//  Created by Ryan Kontos on 7/11/19.
//  Copyright © 2020 Ryan Kontos. All rights reserved.
//

import Foundation
import Cocoa

class MenuUpdateHandler {
    
    let topShelfGen = MenuTopShelfGenerator()
    let upcomingWeekGen = UpcomingWeekMenuGenerator()
    
    
    
    func getMainMenu() -> [NSMenuItem] {
        
        let current = HLLEventSource.shared.getCurrentEvents(includeHidden: true)
        let upcomingDay = HLLEventSource.shared.getUpcomingEventsFromNextDayWithEvents()
        let upcomingAll = HLLEventSource.shared.getArraysOfUpcomingEventsForNextSevenDays(returnEmptyItems: true)
        
        let menuItems = self.topShelfGen.generateTopShelfMenuItems(currentEvents: current, upcomingEventsToday: upcomingDay, moreUpcoming: upcomingAll)
        
        return menuItems
        
    }
    
    
}
